#!/bin/bash

set -e

# 脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NAME="$(basename "${BASH_SOURCE[0]}")"

# 目标目录
DESKTOP_TARGET_DIR="/usr/local/share/applications"
ICON_TARGET_DIR="/usr/local/share/icons/hicolor/48x48/apps"
BIN_TARGET_DIR="/usr/local/bin"
WINE_BIN="/usr/local/bin/wine-staging.AppImage"

# 应用列表配置
# 格式: ("应用名称" "desktop文件" "svg图标文件" "运行脚本")
declare -a APPS=(
    "企业微信" "com.qq.weixin.work.desktop" "com.qq.weixin.work.svg" "wine_app.sh"
    # "微信" "com.qq.weixin.desktop" "com.qq.weixin.svg" "wine_app.sh"
)

# 打印信息
log_info() { echo -e "$(date +'%Y-%m-%d %H:%M:%S') [INFO] $1"; }
log_success() { echo -e "$(date +'%Y-%m-%d %H:%M:%S') [SUCCESS] $1"; }
log_warning() { echo -e "$(date +'%Y-%m-%d %H:%M:%S') [WARNING] $1"; }
log_error() { echo -e "$(date +'%Y-%m-%d %H:%M:%S') [ERROR] $1"; }

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        log_info "Please run: sudo ./$NAME"
        exit 1
    fi
}

# 检查 wine 二进制文件
check_wine_binary() {
    if [[ ! -f "$WINE_BIN" ]]; then
        log_error "wine-staging.AppImage not found: $WINE_BIN"
        log_info "Please download from: https://github.com/mmtrt/WINE_AppImage"
        log_info "And place it at: $WINE_BIN"
        log_info "Then make it executable: chmod +x $WINE_BIN"
        exit 1
    fi
    
    if [[ ! -x "$WINE_BIN" ]]; then
        log_warning "wine-staging.AppImage is not executable, setting permissions..."
        chmod +x "$WINE_BIN"
    fi
    
    log_success "wine-staging.AppImage verified"
}

# 创建目录
create_directories() {
    local dirs=("$DESKTOP_TARGET_DIR" "$ICON_TARGET_DIR" "$BIN_TARGET_DIR")
    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_info "Creating directory: $dir"
            mkdir -p "$dir"
        else
            log_info "Directory exists: $dir"
        fi
    done
}

# 检查文件是否相同
files_are_same() {
    local src="$1" dest="$2"
    [[ ! -f "$dest" ]] && return 1
    cmp -s "$src" "$dest"
}

# 检查源文件是否存在
check_source_files() {
    local app_name="$1" desktop_file="$2" svg_file="$3" script_file="$4"
    local missing_files=()
    
    for file in "$desktop_file" "$svg_file" "$script_file"; do
        if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        log_error "Missing source files for $app_name: ${missing_files[*]}"
        return 1
    fi
    
    return 0
}


# 安装单个应用
install_app() {
    local app_name="$1"
    local desktop_file="$2"
    local svg_file="$3"
    local script_file="$4"
    
    log_info "Installing: $app_name"
    
    # 检查源文件
    if ! check_source_files "$app_name" "$desktop_file" "$svg_file" "$script_file"; then
        return 1
    fi
    
    # 安装 desktop 文件
    local desktop_target="$DESKTOP_TARGET_DIR/$desktop_file"
    if files_are_same "$SCRIPT_DIR/$desktop_file" "$desktop_target"; then
        log_info "Desktop file unchanged: $desktop_file"
    else
        cp "$SCRIPT_DIR/$desktop_file" "$desktop_target"
        log_success "Desktop file installed: $desktop_file"
    fi
    
    # 安装图标文件
    local icon_target="$ICON_TARGET_DIR/$svg_file"
    if files_are_same "$SCRIPT_DIR/$svg_file" "$icon_target"; then
        log_info "Icon file unchanged: $svg_file"
    else
        cp "$SCRIPT_DIR/$svg_file" "$icon_target"
        log_success "Icon file installed: $svg_file"
    fi
    
    # 安装脚本文件
    local script_target="$BIN_TARGET_DIR/$script_file"
    if files_are_same "$SCRIPT_DIR/$script_file" "$script_target"; then
        log_info "Script file unchanged: $script_file"
    else
        cp "$SCRIPT_DIR/$script_file" "$script_target"
        chmod +x "$script_target"
        log_success "Script file installed: $script_file"
    fi
    
    return 0
}

# 安装所有应用
install_all_apps() {
    log_info "Installing ${#APPS[@]} applications..."
    
    local installed_count=0
    local error_count=0
    local total_apps=$((${#APPS[@]} / 4))
    
    for ((i=0; i<${#APPS[@]}; i+=4)); do
        local app_name="${APPS[i]}"
        local desktop_file="${APPS[i+1]}"
        local svg_file="${APPS[i+2]}"
        local script_file="${APPS[i+3]}"
        
        echo
        log_info "=== Processing: $app_name ==="
        
        if install_app "$app_name" "$desktop_file" "$svg_file" "$script_file"; then
            ((installed_count++))
        else
            ((error_count++))
        fi
    done
    
    echo
    log_info "Installation summary: $installed_count/$total_apps apps installed successfully, $error_count errors"
    
    if [[ $error_count -gt 0 ]]; then
        return 1
    fi
    return 0
}

# 验证安装
verify_installation() {
    log_info "Verifying installation..."
    
    local success=true
    local verified_count=0
    
    for ((i=0; i<${#APPS[@]}; i+=4)); do
        local app_name="${APPS[i]}"
        local desktop_file="${APPS[i+1]}"
        local svg_file="${APPS[i+2]}"
        local script_file="${APPS[i+3]}"
        
        # 检查文件是否存在
        if [[ ! -f "$DESKTOP_TARGET_DIR/$desktop_file" ]]; then
            log_error "Missing desktop file: $DESKTOP_TARGET_DIR/$desktop_file"
            success=false
        fi
        
        if [[ ! -f "$ICON_TARGET_DIR/$svg_file" ]]; then
            log_error "Missing icon file: $ICON_TARGET_DIR/$svg_file"
            success=false
        fi
        
        if [[ ! -f "$BIN_TARGET_DIR/$script_file" ]]; then
            log_error "Missing script file: $BIN_TARGET_DIR/$script_file"
            success=false
        elif [[ ! -x "$BIN_TARGET_DIR/$script_file" ]]; then
            log_error "Script not executable: $BIN_TARGET_DIR/$script_file"
            success=false
        else
            ((verified_count++))
        fi
    done
    
    if [[ "$success" == true ]]; then
        log_success "All $verified_count applications verified successfully"
    else
        log_warning "Some applications have issues, please check the errors above"
    fi
}

# 显示应用列表
list_apps() {
    log_info "Available applications:"
    for ((i=0; i<${#APPS[@]}; i+=4)); do
        local app_name="${APPS[i]}"
        local desktop_file="${APPS[i+1]}"
        local svg_file="${APPS[i+2]}"
        local script_file="${APPS[i+3]}"
        
        echo "  - $app_name"
        echo "    Desktop: $desktop_file"
        echo "    Icon: $svg_file"
        echo "    Script: $script_file"
        echo
    done
}

# 显示系统信息
show_system_info() {
    log_info "System Information:"
    echo "  Script directory: $SCRIPT_DIR"
    echo "  Desktop target: $DESKTOP_TARGET_DIR"
    echo "  Icon target: $ICON_TARGET_DIR"
    echo "  Binary target: $BIN_TARGET_DIR"
    echo "  Wine binary: $WINE_BIN"
    echo
}

# 主函数
main() {
    case "${1:-}" in
        -h|--help)
            echo "Usage: $NAME [OPTIONS]"
            echo
            echo "Options:"
            echo "  -h, --help     Show this help message"
            echo "  -l, --list     List available applications"
            echo "  -i, --info     Show system information"
            echo "  -v, --version  Show version information"
            echo
            echo "This script will install the following applications:"
            for ((i=0; i<${#APPS[@]}; i+=4)); do
                echo "  - ${APPS[i]}"
            done
            exit 0
            ;;
        -l|--list)
            list_apps
            exit 0
            ;;
        -i|--info)
            show_system_info
            exit 0
            ;;
        -v|--version)
            echo "Multi-App Installer v2.0"
            echo "Configured applications: $((${#APPS[@]} / 4))"
            exit 0
            ;;
    esac
    
    log_info "Multi-App Installation Started"
    show_system_info
    
    check_root
    check_wine_binary
    create_directories

    if install_all_apps; then
        verify_installation
        log_success "🎉 Installation completed successfully!"
        log_info "You can now find the applications in your application menu"
    else
        log_error "❌ Installation completed with errors"
        exit 1
    fi
}

main "$@"