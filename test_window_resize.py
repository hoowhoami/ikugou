#!/usr/bin/env python3
"""
测试ikugou应用程序的窗口调整大小功能
"""

import subprocess
import time
import sys

def run_applescript(script):
    """运行AppleScript命令"""
    try:
        result = subprocess.run(['osascript', '-e', script], 
                              capture_output=True, text=True, timeout=10)
        return result.returncode == 0, result.stdout.strip(), result.stderr.strip()
    except subprocess.TimeoutExpired:
        return False, "", "Timeout"
    except Exception as e:
        return False, "", str(e)

def test_window_resize():
    """测试窗口调整大小功能"""
    print("🧪 测试ikugou应用程序窗口调整大小功能...")
    
    # 检查应用程序是否运行
    script = '''
    tell application "System Events"
        if exists (process "ikugou") then
            return "running"
        else
            return "not running"
        end if
    end tell
    '''
    
    success, output, error = run_applescript(script)
    if not success or output != "running":
        print("❌ ikugou应用程序未运行")
        return False
    
    print("✅ ikugou应用程序正在运行")
    
    # 获取当前窗口大小
    script = '''
    tell application "System Events"
        tell process "ikugou"
            tell window 1
                return {size, position}
            end tell
        end tell
    end tell
    '''
    
    success, output, error = run_applescript(script)
    if success:
        print(f"📏 当前窗口信息: {output}")
    
    # 测试调整窗口大小到1400x900
    print("🔄 测试调整窗口大小到1400x900...")
    script = '''
    tell application "System Events"
        tell process "ikugou"
            tell window 1
                set size to {1400, 900}
            end tell
        end tell
    end tell
    '''
    
    success, output, error = run_applescript(script)
    if success:
        print("✅ 窗口大小调整成功")
    else:
        print(f"❌ 窗口大小调整失败: {error}")
    
    time.sleep(1)
    
    # 验证新的窗口大小
    script = '''
    tell application "System Events"
        tell process "ikugou"
            tell window 1
                return size
            end tell
        end tell
    end tell
    '''
    
    success, output, error = run_applescript(script)
    if success:
        print(f"📏 调整后窗口大小: {output}")
    
    # 测试最小窗口大小限制
    print("🔄 测试最小窗口大小限制 (尝试设置为800x600)...")
    script = '''
    tell application "System Events"
        tell process "ikugou"
            tell window 1
                set size to {800, 600}
            end tell
        end tell
    end tell
    '''
    
    success, output, error = run_applescript(script)
    time.sleep(1)
    
    # 检查是否被限制到最小大小
    script = '''
    tell application "System Events"
        tell process "ikugou"
            tell window 1
                return size
            end tell
        end tell
    end tell
    '''
    
    success, output, error = run_applescript(script)
    if success:
        print(f"📏 最小大小限制测试结果: {output}")
        if "1200" in output:
            print("✅ 最小窗口大小限制工作正常 (应该是1200x800)")
        else:
            print("⚠️  最小窗口大小限制可能未生效")
    
    return True

if __name__ == "__main__":
    test_window_resize()
