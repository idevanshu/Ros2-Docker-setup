<body style='font-family:Segoe UI,sans-serif;max-width:900px;margin:40px auto;padding:0 20px;background:#0d1117;color:#c9d1d9;line-height:1.7;'>
<h1 style='color:#58a6ff;border-bottom:2px solid #21262d;padding-bottom:14px;'>ROS 2 Humble &mdash; Docker Setup Guide</h1>
<p><b>Multi-GPU Support</b> &nbsp;|&nbsp; <b>Auto GPU Detection</b> &nbsp;|&nbsp; <b>ROS 2 Humble</b> &nbsp;|&nbsp; <b>Docker</b> &nbsp;|&nbsp; <b>Windows 11 / WSL 2</b></p>
<p>This guide walks through setting up a <b>fully containerized ROS 2 Humble development environment</b> on Windows using Docker Desktop and WSL 2. The setup script <b>automatically detects your GPU</b> (NVIDIA, AMD, or Intel) and generates the correct Dockerfile and docker-compose.yml. Systems with <b>multiple GPUs</b> are fully supported &mdash; NVIDIA is prioritised when detected.</p>
<h2 style='color:#58a6ff;border-left:4px solid #1f6feb;padding-left:12px;margin-top:40px;'>Prerequisites</h2>
<p><b>Docker Desktop</b> &mdash; With WSL 2 backend enabled. Must be running before any docker commands.</p>
<p><b>PowerShell 5.1+ or 7</b> &mdash; Built into Windows 10/11. PowerShell 7 (pwsh) is recommended to avoid encoding issues.</p>
<p><b>NVIDIA Container Toolkit</b> (NVIDIA only) &mdash; Must be installed inside your WSL 2 distro to enable GPU passthrough into Docker.</p>
<p><b>X Server / VcXsrv</b> (Optional) &mdash; Required only if you want GUI tools like RViz to display on your Windows desktop.</p>
<h2 style='color:#58a6ff;border-left:4px solid #1f6feb;padding-left:12px;margin-top:40px;'>How the Script Works</h2>
<p>The script <b>setup_ros2_auto.ps1</b> is a one-shot bootstrapper. It does 5 things in order:</p>
<p><b>Step 1 &mdash; GPU Detection:</b> Queries Win32_VideoController for all installed GPUs and sets a NVIDIA flag if any GPU name matches NVIDIA.</p>
<p><b>Step 2 &mdash; Dockerfile Generation:</b> Writes a tailored Dockerfile based on detected GPU type with the correct drivers and environment variables.</p>
<p><b>Step 3 &mdash; docker-compose.yml:</b> Generates a compose file with correct GPU passthrough, X11 forwarding, and volume mounts.</p>
<p><b>Step 4 &mdash; Workspace Folder:</b> Creates a local workspace/ folder on Windows that is mounted live into the container at /ros2_ws.</p>
<p><b>Step 5 &mdash; Build and Launch:</b> Runs docker compose build then docker compose up -d to start the container automatically.</p>
<h2 style='color:#58a6ff;border-left:4px solid #1f6feb;padding-left:12px;margin-top:40px;'>Multi-GPU Detection Logic</h2>
<p>On systems with multiple GPUs the script scans all video controllers and applies this priority:</p>
<table style='width:100%;border-collapse:collapse;font-size:14px;margin:14px 0;'>
<tr style='background:#1f6feb;color:#fff;'><th style='padding:10px;text-align:left;'>Scenario</th><th style='padding:10px;text-align:left;'>GPUs Detected</th><th style='padding:10px;text-align:left;'>Config Applied</th></tr>
<tr><td style='padding:10px;border-bottom:1px solid #21262d;'>NVIDIA only</td><td style='padding:10px;border-bottom:1px solid #21262d;'>Single NVIDIA GPU</td><td style='padding:10px;border-bottom:1px solid #21262d;'>NVIDIA Container Toolkit path</td></tr>
<tr style='background:#161b22;'><td style='padding:10px;border-bottom:1px solid #21262d;'>NVIDIA + AMD/Intel</td><td style='padding:10px;border-bottom:1px solid #21262d;'>Multiple GPUs, NVIDIA present</td><td style='padding:10px;border-bottom:1px solid #21262d;'>NVIDIA path (NVIDIA takes priority)</td></tr>
<tr><td style='padding:10px;border-bottom:1px solid #21262d;'>AMD only</td><td style='padding:10px;border-bottom:1px solid #21262d;'>AMD GPU, no NVIDIA</td><td style='padding:10px;border-bottom:1px solid #21262d;'>Mesa + D3D12 WSL2 passthrough</td></tr>
<tr style='background:#161b22;'><td style='padding:10px;border-bottom:1px solid #21262d;'>Intel integrated only</td><td style='padding:10px;border-bottom:1px solid #21262d;'>Intel GPU, no NVIDIA</td><td style='padding:10px;border-bottom:1px solid #21262d;'>Mesa + D3D12 WSL2 passthrough</td></tr>
<tr><td style='padding:10px;'>AMD + Intel</td><td style='padding:10px;'>Multiple GPUs, no NVIDIA</td><td style='padding:10px;'>Mesa + D3D12 WSL2 passthrough</td></tr>
</table>
<p><b>NVIDIA path</b> sets NVIDIA_VISIBLE_DEVICES=all, NVIDIA_DRIVER_CAPABILITIES, and uses deploy.resources in docker-compose.yml.</p>
<p><b>AMD/Intel path</b> installs mesa-utils and libgl1-mesa-dri, sets GALLIUM_DRIVER=d3d12, and mounts /usr/lib/wsl, /dev/dri, and /dev/dxg.</p>
<h2 style='color:#58a6ff;border-left:4px solid #1f6feb;padding-left:12px;margin-top:40px;'>Step-by-Step: Running the Script</h2>
<p><b>1. Allow PowerShell scripts to run</b> (run as Administrator once):</p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'>Set-ExecutionPolicy RemoteSigned -Scope CurrentUser</code></pre>
<p><b>2. Navigate to the script folder and run it:</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'>cd C:/Users/ASUS/Desktop/Puskpako2/ros2_setup_guide
.\setup_ros2_auto.ps1</code></pre>
<p><b>3. After build completes, start the container:</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'>docker compose up -d</code></pre>
<p><b>4. Attach to the running container:</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'>docker exec -it ros2_auto_container bash</code></pre>
<p><b>5. Verify ROS 2 is active:</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'>printenv ROS_DISTRO
# Output: humble</code></pre>
<p><b>6. Run the talker and listener test:</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'># Terminal 1 inside container
ros2 run demo_nodes_cpp talker

# Terminal 2 open a new PowerShell window
docker exec -it ros2_auto_container bash
ros2 run demo_nodes_cpp listener</code></pre>
<p>Expected output:</p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#3fb950;font-family:Courier New,monospace;'>[talker]   Publishing: Hello World: 1
[listener] I heard: Hello World: 1</code></pre>
<hr style='border:none;border-top:1px solid #21262d;margin:40px 0;'/>
<h2 style='color:#58a6ff;border-left:4px solid #1f6feb;padding-left:12px;margin-top:40px;'>Errors Encountered &amp; Fixes</h2>
<p style='background:#1a1014;border:1px solid #da3633;border-left:4px solid #da3633;border-radius:8px;padding:16px;'><b style='color:#ff7b72;'>Error 1 &mdash; PowerShell Here-String Parse Errors</b><br/><span style='color:#ffa198;'>The from keyword is not supported... The token &amp;&amp; is not a valid statement separator... Unexpected token in expression or statement.</span></p>
<p><b>Cause:</b> The script was saved with incorrect encoding or the closing &quot;@ of here-strings had leading spaces. PowerShell 5.1 requires &quot;@ to be at column 0 with zero indentation. Emoji characters also caused parse failures.</p>
<p><b>Fix A &mdash; Re-save with UTF-8 BOM encoding:</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'>$content = Get-Content -Path &quot;.\setup_ros2_auto.ps1&quot; -Raw
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText(&quot;$PWD\setup_ros2_auto.ps1&quot;, $content, $utf8Bom)</code></pre>
<p><b>Fix B &mdash; Install and use PowerShell 7:</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'>winget install Microsoft.PowerShell
# Then open pwsh and run the script from there</code></pre>
<p><b>Fix C &mdash; Replace here-strings with backtick-n strings (permanent fix):</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'># BROKEN in PS 5.1 (indented closing tag breaks parsing)
$content = @&quot;
    FROM osrf/ros:humble-desktop
    &quot;@

# WORKS everywhere (use explicit newlines instead)
$content = &quot;FROM osrf/ros:humble-desktop`nWORKDIR /ros2_ws&quot;</code></pre>
<p style='background:#1a1014;border:1px solid #da3633;border-left:4px solid #da3633;border-radius:8px;padding:16px;margin-top:24px;'><b style='color:#ff7b72;'>Error 2 &mdash; Docker Daemon Not Running</b><br/><span style='color:#ffa198;'>failed to connect to the docker API at npipe:////./pipe/dockerDesktopLinuxEngine; check if the path is correct and if the daemon is running.</span></p>
<p><b>Cause:</b> Docker Desktop was not open or the WSL 2 Linux engine had not fully started yet. The script ran fine but could not reach the Docker socket.</p>
<p><b>Fix &mdash; Start Docker Desktop, wait for Engine running status, then verify and re-run:</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'>docker info
# Must return info without errors before continuing

docker compose build
docker compose up -d

# If still failing restart Docker Desktop as Administrator
Restart-Service com.docker.service</code></pre>
<p style='background:#1a1014;border:1px solid #da3633;border-left:4px solid #da3633;border-radius:8px;padding:16px;margin-top:24px;'><b style='color:#ff7b72;'>Error 3 &mdash; docker-compose.yml version attribute warning</b><br/><span style='color:#ffa198;'>the attribute version is obsolete, it will be ignored, please remove it to avoid potential confusion.</span></p>
<p><b>Cause:</b> Docker Compose v2 deprecated the top-level version field. It is harmless but prints a warning on every command.</p>
<p><b>Fix &mdash; Delete the version line from docker-compose.yml:</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'># DELETE this line:
version: 3.8

# File must now start directly with:
services:
  ros2_dev:
    build: .
    ...</code></pre>
<p style='background:#1a1014;border:1px solid #da3633;border-left:4px solid #da3633;border-radius:8px;padding:16px;margin-top:24px;'><b style='color:#ff7b72;'>Error 4 &mdash; ros2 --version not recognized</b><br/><span style='color:#ffa198;'>ros2: error: unrecognized arguments: --version</span></p>
<p><b>Cause:</b> The ROS 2 CLI does not support a --version flag. This is expected behavior and does not mean your installation is broken.</p>
<p><b>Fix &mdash; Use the correct commands to verify ROS 2:</b></p>
<pre style='background:#161b22;border:1px solid #30363d;border-radius:8px;padding:16px;overflow-x:auto;'><code style='color:#79c0ff;font-family:Courier New,monospace;'>printenv ROS_DISTRO
# Output: humble

ros2 doctor --report | grep &quot;ROS 2&quot;
# Output: ROS 2 INFORMATION

ros2 pkg list | head -10
# Lists installed packages confirming middleware works</code></pre>
<hr style='border:none;border-top:1px solid #21262d;margin:40px 0;'/>
<h2 style='color:#58a6ff;border-left:4px solid #1f6feb;padding-left:12px;margin-top:40px;'>Quick Reference</h2>
<table style='width:100%;border-collapse:collapse;font-size:14px;margin:14px 0;'>
<tr style='background:#1f6feb;color:#fff;'><th style='padding:10px;text-align:left;'>Task</th><th style='padding:10px;text-align:left;'>Command</th></tr>
<tr><td style='padding:10px;border-bottom:1px solid #21262d;'>Build image</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>docker compose build</code></td></tr>
<tr style='background:#161b22;'><td style='padding:10px;border-bottom:1px solid #21262d;'>Start container</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>docker compose up -d</code></td></tr>
<tr><td style='padding:10px;border-bottom:1px solid #21262d;'>Attach shell</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>docker exec -it ros2_auto_container bash</code></td></tr>
<tr style='background:#161b22;'><td style='padding:10px;border-bottom:1px solid #21262d;'>Stop container</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>docker compose down</code></td></tr>
<tr><td style='padding:10px;border-bottom:1px solid #21262d;'>Check ROS distro</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>printenv ROS_DISTRO</code></td></tr>
<tr style='background:#161b22;'><td style='padding:10px;border-bottom:1px solid #21262d;'>Run talker test</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>ros2 run demo_nodes_cpp talker</code></td></tr>
<tr><td style='padding:10px;border-bottom:1px solid #21262d;'>Run listener test</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>ros2 run demo_nodes_cpp listener</code></td></tr>
<tr style='background:#161b22;'><td style='padding:10px;border-bottom:1px solid #21262d;'>Launch RViz</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>rviz2</code></td></tr>
<tr><td style='padding:10px;border-bottom:1px solid #21262d;'>List nodes</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>ros2 node list</code></td></tr>
<tr style='background:#161b22;'><td style='padding:10px;border-bottom:1px solid #21262d;'>List topics</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>ros2 topic list</code></td></tr>
<tr><td style='padding:10px;border-bottom:1px solid #21262d;'>Build workspace</td><td style='padding:10px;border-bottom:1px solid #21262d;'><code style='color:#79c0ff;'>colcon build</code></td></tr>
<tr style='background:#161b22;'><td style='padding:10px;'>Source workspace</td><td style='padding:10px;'><code style='color:#79c0ff;'>source install/setup.bash</code></td></tr>
</table>
<div style='background:#0d1f0f;border:1px solid #238636;border-radius:10px;padding:20px 24px;text-align:center;margin-top:40px;'>
<h2 style='color:#3fb950;border:none;padding:0;margin:0 0 8px 0;'>Setup Complete</h2>
<p style='color:#aff5b4;margin:0;'>ROS 2 Humble is running inside Docker with <b>automatic multi-GPU detection (NVIDIA &amp; AMD/Intel)</b>. Your <b>workspace/</b> folder is live-mounted at <b>/ros2_ws</b> &mdash; edit files on Windows, build and run inside the container.</p>
</div>
</body>

