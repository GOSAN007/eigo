-- ============================================================
--  英検準2級 単語テスト — 家長モード用スキーマ
--  Supabase ダッシュボード → SQL Editor に貼り付けて一度だけ実行
--  （既存の word_errors と同じプロジェクトで実行してください）
-- ============================================================

-- 1) 各テスト結果の記録 -------------------------------------------------
create table if not exists public.test_sessions (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  range_from  int,                 -- 出題範囲 開始 No.（範囲指定なしモードは NULL）
  range_to    int,                 -- 出題範囲 終了 No.
  mode        text,                -- order / random / errors / wrongRandom / retryWrong
  total       int  not null,       -- 出題数
  correct     int  not null,       -- 正解数
  wrong       int  not null,       -- 不正解数
  device      text                 -- 端末識別子（タブレット等の区別用）
);

create index if not exists test_sessions_created_at_idx
  on public.test_sessions (created_at desc);

-- 2) 設定保存（保護者パスワードのハッシュ等の key/value） ----------------
create table if not exists public.app_config (
  key         text primary key,
  value       text,
  updated_at  timestamptz not null default now()
);

-- 3) アクセス権（publishable / anon キーで読み書き。word_errors と同方針） --
alter table public.test_sessions enable row level security;
alter table public.app_config    enable row level security;

drop policy if exists anon_all on public.test_sessions;
create policy anon_all on public.test_sessions
  for all to anon, authenticated using (true) with check (true);

drop policy if exists anon_all on public.app_config;
create policy anon_all on public.app_config
  for all to anon, authenticated using (true) with check (true);

grant all on public.test_sessions to anon, authenticated;
grant all on public.app_config    to anon, authenticated;
