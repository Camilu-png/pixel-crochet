-- Preserve existing projects and ownership policies while allowing larger charts.
alter table public.user_projects
  drop constraint if exists user_projects_project_size_limit;
alter table public.user_projects
  add constraint user_projects_project_size_limit
  check (octet_length(project::text) <= 1048576);
