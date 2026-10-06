-- Pixel Crochet private project backups. Apply from the Supabase SQL Editor or
-- Supabase CLI after creating a project; this migration is never run by Flutter.
create table if not exists public.user_projects (
  user_id uuid not null references auth.users (id) on delete cascade,
  id text not null,
  project jsonb not null,
  revision bigint not null default 1 check (revision > 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, id),
  constraint user_projects_project_is_object
    check (jsonb_typeof(project) = 'object'),
  constraint user_projects_project_id_matches
    check (
      jsonb_typeof(project -> 'id') = 'string'
      and (project ->> 'id' = id) is true
    ),
  constraint user_projects_project_size_limit
    check (octet_length(project::text) <= 262144)
);

alter table public.user_projects enable row level security;

create policy "Users can read their own project backups"
  on public.user_projects for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users can create their own project backups"
  on public.user_projects for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

create policy "Users can update their own project backups"
  on public.user_projects for update
  to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "Users can delete their own project backups"
  on public.user_projects for delete
  to authenticated
  using ((select auth.uid()) = user_id);

create index if not exists user_projects_updated_at_idx
  on public.user_projects (user_id, updated_at desc);

revoke all on public.user_projects from anon;
grant select, insert, update, delete on public.user_projects to authenticated;
