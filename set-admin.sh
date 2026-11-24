#!/usr/bin/env bash
# set-admin.sh — 设置后台登录密码（>=12 位），并把管理员显示名固定为 ganyu143。
# 用法：read -rs p; printf %s "$p" | ./set-admin.sh   （不要把密码写进命令行）
set -euo pipefail
cd "$(dirname "$0")"
pw=$(cat)
if [ "${#pw}" -lt 12 ]; then echo "密码不足 12 位，未改动"; exit 2; fi
cp -a .env ".env.bak-$(date +%Y%m%d-%H%M%S)"
python3 - "$pw" <<PY
import sys,re,pathlib
pw=sys.argv[1]
p=pathlib.Path(".env"); t=p.read_text()
t=re.sub(r"^ADMIN_PASSWORD=.*$", "ADMIN_PASSWORD="+pw, t, flags=re.M)
p.write_text(t); p.chmod(0o600)
PY
docker compose -f docker-compose.host.yml up -d api worker web 2>&1 | tail -2
sql="insert into admin_users (email, display_name)"
sql="insert into admin_users (email, display_name)"
sql="$sql values (\x27admin@local\x27, \x27ganyu143\x27)"
sql="$sql on conflict (email) do update"
sql="$sql set display_name = excluded.display_name"
