#!/bin/bash
# mojo_build.sh — RQAlpha Mojo 智能编译辅助工具
# 根据目标文件自动选择最优 -I 参数集，避免解析无关第三方包
#
# 用法:
#   ./mojo_build.sh build <file.mojo>        # 编译
#   ./mojo_build.sh run <file.mojo>         # 运行
#   ./mojo_build.sh test <test_file.mojo>  # 运行测试
#   ./mojo_build.sh profile <file.mojo>     # 显示使用的配置层
#
# 环境变量:
#   MOJO_BUILD_PROFILE=light|standard|full  # 强制指定配置层

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
MOJO_BIN="${MOJO_BIN:-$HOME/hello_mojo/trae_cn_78/.venv/bin/mojo}"

export LD_PRELOAD="${LD_PRELOAD:-$HOME/.local/share/uv/python/cpython-3.14.3-linux-x86_64-gnu/lib/libpython3.14.so}"
export PYTHONPATH="${PYTHONPATH:-$HOME/hello_mojo/trae_cn_78/.venv/lib/python3.14/site-packages}"

BASE_ARGS="-I $PROJECT_ROOT"

declare -A PKG_PATHS=(
    [argmojo]="$PROJECT_ROOT/rqmojo/third_party/argmojo/src"
    [emberjson]="$PROJECT_ROOT/rqmojo/third_party/EmberJson"
    [numojo]="$PROJECT_ROOT/rqmojo/third_party/NuMojo"
    [yaml]="$PROJECT_ROOT/rqmojo/third_party/mojo-yaml/src"
    [morrow]="$PROJECT_ROOT/rqmojo/third_party/morrow.mojo"
)

detect_profile() {
    local file="$1"
    # Support both absolute and relative paths
    if [[ ! "$file" = /* ]]; then
        file="$PROJECT_ROOT/$file"
    fi
    local basename_file=$(basename "$file")

    case "$basename_file" in
        # === light 层：仅需 morrow (核心类型) ===
        simulation_event_source* | plot* | test_* | datetime_func* | typing*)
            echo "light"
            ;;
        # === standard 层：+ argmojo (CLI参数) ===
        matcher* | slippage* | mod* | position_validator* | interface* | event_source*)
            echo "standard"
            ;;
        # === full 层：全部包 ===
        strategy_universe* | adjust* | data_source* | bundle* | trader* | risk* | analyser_mod*)
            echo "full"
            ;;
        *)
            # 默认使用 light（大多数文件不需要额外包）
            echo "light"
            ;;
    esac
}

build_args_for_profile() {
    local profile="${1:-${MOJO_BUILD_PROFILE:-auto}}"

    if [[ "$profile" == "auto" ]]; then
        profile=$(detect_profile "${TARGET_FILE:-}")
    fi

    case "$profile" in
        light)
            echo "$BASE_ARGS -I ${PKG_PATHS[morrow]}"
            ;;
        standard)
            echo "$BASE_ARGS -I ${PKG_PATHS[morrow]} -I ${PKG_PATHS[argmojo]}"
            ;;
        full)
            echo "$BASE_ARGS -I ${PKG_PATHS[argmojo]} -I ${PKG_PATHS[emberjson]} -I ${PKG_PATHS[numojo]} -I ${PKG_PATHS[yaml]} -I ${PKG_PATHS[morrow]}"
            ;;
        *)
            echo "ERROR: Unknown profile '$profile'. Use: light, standard, full, auto" >&2
            exit 1
            ;;
    esac
}

show_info() {
    local file="$1"
    local profile
    profile=$(detect_profile "$file")
    local args
    args=$(build_args_for_profile "$profile")
    
    echo "=== Mojo Build Info ==="
    echo "Target:      $file"
    echo "Profile:     $profile"
    echo "Args:        $args"
    echo ""
    echo "Package breakdown:"
    case "$profile" in
        light)
            echo "  ✅ morrow.mojo       (1,347 lines)  — DateTime type"
            echo "  ❌ argmojo           skipped          — CLI only"
            echo "  ❌ EmberJson         skipped          — JSON only"
            echo "  ❌ NuMojo            skipped          — unused"
            echo "  ❌ mojo-yaml         skipped          — YAML only"
            echo ""
            echo "  Saved: ~140,000 lines of unnecessary parsing"
            ;;
        standard)
            echo "  ✅ morrow.mojo       (1,347 lines)  — DateTime type"
            echo "  ✅ argmojo           (20,090 lines) — CLI parsing"
            echo "  ❌ EmberJson         skipped          — JSON only"
            echo "  ❌ NuMojo            skipped          — unused"
            echo "  ❌ mojo-yaml         skipped          — YAML only"
            echo ""
            echo "  Saved: ~120,000 lines of unnecessary parsing"
            ;;
        full)
            echo "  ✅ All 5 packages included (no optimization)"
            ;;
    esac
}

do_build() {
    local file="$1"
    if [[ ! "$file" = /* ]]; then
        file="$PROJECT_ROOT/$file"
    fi
    local profile
    profile=$(detect_profile "$file")
    local args
    args=$(build_args_for_profile "$profile")

    echo "[mojo_build] profile=$profile building: $file"
    exec "$MOJO_BIN" build $args "$file" 2>&1
}

do_run() {
    local file="$1"
    if [[ ! "$file" = /* ]]; then
        file="$PROJECT_ROOT/$file"
    fi
    local profile
    profile=$(detect_profile "$file")
    local args
    args=$(build_args_for_profile "$profile")

    echo "[mojo_build] profile=$profile running: $file"
    exec "$MOJO_BIN" run $args "$file" 2>&1
}

main() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <build|run|test|profile> <file.mojo>" >&2
        echo "" >&2
        echo "Profiles:" >&2
        echo "  light     — core only (morrow). For: plot, test, simulation_event_source" >&2
        echo "  standard  — + argmojo. For: matcher, mod, slippage, interface" >&2
        echo "  full      — all packages. For: strategy_universe, adjust, data_source" >&2
        echo "" >&2
        echo "Env var MOJO_BUILD_PROFILE=light|standard|full to force profile" >&2
        exit 1
    fi

    local cmd="$1"
    local raw_target="$2"
    # Support both absolute and relative paths
    if [[ ! "$raw_target" = /* ]]; then
        TARGET_FILE="$PROJECT_ROOT/$raw_target"
    else
        TARGET_FILE="$raw_target"
    fi
    shift 2

    case "$cmd" in
        build) do_build "$TARGET_FILE" ;;
        run) do_run "$TARGET_FILE" ;;
        test) do_run "$TARGET_FILE" ;;  # same as run for .mojo tests
        profile) show_info "$TARGET_FILE" ;;
        *) echo "Unknown command: $cmd. Use: build, run, test, profile" >&2; exit 1 ;;
    esac
}

main "$@"
