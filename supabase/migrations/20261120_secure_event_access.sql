-- Kiany & Julieta: autenticação simples e check-in seguro
-- Preparado para execução manual após backup. NÃO executar sem ler SECURITY-REVIEW.md.
-- Preserva convidados e histórico: apenas adiciona colunas/índice e substitui políticas/função.

begin;

alter table public.checkin_logs
  add column if not exists checkin_uuid text,
  add column if not exists is_offline_sync boolean not null default false;

create unique index if not exists checkin_logs_checkin_uuid_uidx
  on public.checkin_logs (checkin_uuid)
  where checkin_uuid is not null;

-- Remover políticas permissivas antigas e qualquer política residual destas tabelas.
do $$
declare p record;
begin
  for p in
    select schemaname, tablename, policyname
    from pg_policies
    where schemaname='public' and tablename in ('guests','checkin_logs')
  loop
    execute format('drop policy if exists %I on %I.%I', p.policyname, p.schemaname, p.tablename);
  end loop;
end $$;

alter table public.guests enable row level security;
alter table public.checkin_logs enable row level security;

revoke all on table public.guests from anon, public;
revoke all on table public.checkin_logs from anon, public;
grant select, insert, update, delete on table public.guests to authenticated;
grant select on table public.checkin_logs to authenticated;
revoke insert, update, delete on table public.checkin_logs from authenticated;

create policy guests_admin_all
  on public.guests for all to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin')
  with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

create policy guests_gate_read
  on public.guests for select to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') in ('gate','admin'));

create policy checkin_logs_admin_read
  on public.checkin_logs for select to authenticated
  using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'admin');

-- Retirar a versão antiga de 3 argumentos para eliminar ambiguidade.
drop function if exists public.process_checkin(text, integer, text);

create or replace function public.process_checkin(
  p_token text,
  p_count integer,
  p_checkin_uuid text default null,
  p_gate text default 'Portaria Principal',
  p_is_offline boolean default false
)
returns json
language plpgsql
security definer
set search_path = pg_catalog, public, pg_temp
as $function$
declare
  v_guest public.guests%rowtype;
  v_log public.checkin_logs%rowtype;
begin
  if coalesce(auth.jwt() -> 'app_metadata' ->> 'role','') not in ('gate','admin') then
    raise exception 'Acesso não autorizado' using errcode='42501';
  end if;

  if p_count is null or p_count < 1 then
    return json_build_object('success',false,'reason','invalid_count','message','A quantidade deve ser maior que zero.');
  end if;

  if p_token is null or length(trim(p_token)) = 0 then
    return json_build_object('success',false,'reason','invalid_token');
  end if;

  if p_checkin_uuid is null or length(trim(p_checkin_uuid)) = 0 then
    return json_build_object('success',false,'reason','missing_checkin_id');
  end if;

  -- Serializa reenvios com o mesmo identificador para impedir duplicações.
  perform pg_advisory_xact_lock(hashtextextended(p_checkin_uuid, 0));

  select * into v_log
  from public.checkin_logs
  where checkin_uuid = p_checkin_uuid;

  if found then
    select * into v_guest from public.guests where id = v_log.guest_id;
    return json_build_object(
      'success',true,'idempotent',true,
      'guest_name',v_log.guest_name,
      'quota',coalesce(v_guest.quota,0),
      'new_used',coalesce(v_guest.used,0),
      'table_name',coalesce(v_guest.table_name,'Livre')
    );
  end if;

  select * into v_guest
  from public.guests
  where token = p_token
  for update;

  if not found then
    return json_build_object('success',false,'reason','not_found');
  end if;

  if v_guest.used + p_count > v_guest.quota then
    return json_build_object(
      'success',false,'reason','exhausted',
      'guest_name',v_guest.name,'quota',v_guest.quota,
      'used',v_guest.used,'table_name',v_guest.table_name
    );
  end if;

  update public.guests
  set used = used + p_count
  where id = v_guest.id
  returning * into v_guest;

  insert into public.checkin_logs
    (checkin_uuid, guest_id, guest_name, count_entered, gate_name, is_offline_sync)
  values
    (p_checkin_uuid, v_guest.id, v_guest.name, p_count,
     coalesce(nullif(trim(p_gate),''),'Portaria Principal'), coalesce(p_is_offline,false));

  return json_build_object(
    'success',true,'idempotent',false,
    'guest_name',v_guest.name,'quota',v_guest.quota,
    'new_used',v_guest.used,'table_name',v_guest.table_name
  );
end;
$function$;

revoke all on function public.process_checkin(text, integer, text, text, boolean) from public, anon;
grant execute on function public.process_checkin(text, integer, text, text, boolean) to authenticated;

commit;
