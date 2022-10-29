# 
<p align="center">
<img src="./img/icon.png" width="200" height="200" />
</p>
<h1 align="center">PD Patcher</h1>
<h3 align="center">v18.0.3</h3>
<h3 align="center">适用于 Apple Silicon & Intel 的 PD 补丁</h3>
<p align="center">本项目仅用于学习研究使用</p>



## 运行截图
<p align="center"><img src="./img/screenshot.png" width="720" /></p>  

## 使用
运行 PKG 安装包，根据提示进行安装。

如果您的 Mac 具有 Touch ID，按下指纹即可授权，或输入密码以授权。

授权后，PD Patcher 将进行补丁安装。安装完成后会启动 PD。

## 手动构建 PD Patcher
需要 Python 3.5 以上版本。
```bash
python3 generate.py
```

## 常见问题
**1. 显示「无法打开“PDPatcher.pkg”，因为无法验证开发者。」怎么办？**  
> 右击 PDPatcher.pkg ，选择 “打开” ，然后点击 “打开” 按钮。  
> 或者，在「终端」中，执行 `xattr -r -d com.apple.quarantine PDPatcher.pkg`。  

**2. 安装过程中，显示 "Permission denied: no write access"**  
> 在 “安全性与隐私” 设置中，检查 “完全磁盘访问权限” 、 “App 管理” 中是否拒绝了 “安装器.app” 的权限。

**3. 如何卸载本补丁？**  
> 卸载或者重新安装 PD 即可卸载本补丁。   

**4. PD Patcher 安全吗？**  
> PD Patcher 的源代码完全开放。您可以自行验证其安全性，或自行构建 PD Patcher。  
