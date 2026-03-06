Write-Host "Initializing Smart ROS 2 Humble Docker Environment..." -ForegroundColor Cyan

Write-Host "Scanning for GPU hardware..." -ForegroundColor Yellow
$gpus = Get-CimInstance Win32_VideoController
$hasNvidia = $false
$gpuNames = @()

foreach ($gpu in $gpus) {
    $gpuNames += $gpu.Name
    if ($gpu.Name -match "NVIDIA") {
        $hasNvidia = $true
    }
}

Write-Host "Detected GPUs: $($gpuNames -join ', ')" -ForegroundColor Gray

if ($hasNvidia) {
    Write-Host "NVIDIA GPU detected. Configuring for NVIDIA Container Toolkit..." -ForegroundColor Green
    $dockerfileContent = "FROM osrf/ros:humble-desktop`n`nENV NVIDIA_VISIBLE_DEVICES all`nENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute`n`nRUN apt-get update && apt-get install -y \`n    python3-pip \`n    python3-colcon-common-extensions \`n    nano \`n    git \`n    && rm -rf /var/lib/apt/lists/*`n`nRUN echo 'source /opt/ros/humble/setup.bash' >> ~/.bashrc`nWORKDIR /ros2_ws"
} else {
    Write-Host "AMD/Intel GPU detected. Configuring for WSL 2 D3D12 Passthrough..." -ForegroundColor Blue
    $dockerfileContent = "FROM osrf/ros:humble-desktop`n`nRUN apt-get update && apt-get install -y \`n    python3-pip \`n    python3-colcon-common-extensions \`n    nano \`n    git \`n    mesa-utils \`n    libgl1-mesa-dri \`n    libglx-mesa0 \`n    && rm -rf /var/lib/apt/lists/*`n`nRUN echo 'source /opt/ros/humble/setup.bash' >> ~/.bashrc`nWORKDIR /ros2_ws"
}
Set-Content -Path Dockerfile -Value $dockerfileContent
Write-Host "Created tailored Dockerfile" -ForegroundColor Green

if ($hasNvidia) {
    $composeContent = "version: '3.8'`n`nservices:`n  ros2_dev:`n    build: .`n    container_name: ros2_auto_container`n    stdin_open: true`n    tty: true`n    network_mode: host`n    environment:`n      - DISPLAY=:0`n      - QT_X11_NO_MITSHM=1`n    volumes:`n      - /tmp/.X11-unix:/tmp/.X11-unix:rw`n      - ./workspace:/ros2_ws`n    deploy:`n      resources:`n        reservations:`n          devices:`n            - driver: nvidia`n              count: 1`n              capabilities: [gpu, compute, graphics, utility]"
} else {
    $composeContent = "version: '3.8'`n`nservices:`n  ros2_dev:`n    build: .`n    container_name: ros2_auto_container`n    stdin_open: true`n    tty: true`n    network_mode: host`n    environment:`n      - DISPLAY=:0`n      - QT_X11_NO_MITSHM=1`n      - GALLIUM_DRIVER=d3d12`n      - LIBGL_ALWAYS_SOFTWARE=0`n      - LD_LIBRARY_PATH=/usr/lib/wsl/lib`n    volumes:`n      - /tmp/.X11-unix:/tmp/.X11-unix:rw`n      - /usr/lib/wsl:/usr/lib/wsl:ro`n      - ./workspace:/ros2_ws`n    devices:`n      - /dev/dri:/dev/dri`n      - /dev/dxg:/dev/dxg"
}
Set-Content -Path docker-compose.yml -Value $composeContent
Write-Host "Created tailored docker-compose.yml" -ForegroundColor Green

if (-Not (Test-Path "workspace")) {
    New-Item -ItemType Directory -Path "workspace" | Out-Null
    Write-Host "Created local workspace directory" -ForegroundColor Green
}

Write-Host "Building the Docker image..." -ForegroundColor Yellow
docker compose build

Write-Host "Starting the container..." -ForegroundColor Yellow
docker compose up -d

Write-Host "Setup Complete! Attach to your container using:" -ForegroundColor Green
Write-Host "docker exec -it ros2_auto_container bash" -ForegroundColor Cyan
