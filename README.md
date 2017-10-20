# AWS S3 Proxy 設定

## Step 1. 建立 Image

透過本專案 `dockerfile` 建立 Image。

```
git clone <URL> <local>
docker build -t <image name> <local>
```

接下來可以喝杯咖啡等待 `Image` 建立完成。

## Step 2. 建立 Container

```
docker run -d -it -p <host port>:<container port> --name=<container name> <image name>
```

## Step 3. 設定 Container

### 將 `nginx` 設定檔複製到 Container 內

```
docker cp <local>/config/image <container name Or container id>:/etc/nginx/sites-available/image
```

### 進入容器

```
docker exec -it <container name Or container id> bash
```

### 新增快取資料夾

```
mkdir -p /var/nginx/cache/aws
```

預設位置是 `/var/nginx/cache/aws` 如果要異動，一併要修改 `config\image`。


### 設定軟連結

```
ln -s /etc/nginx/sites-available/image /etc/nginx/sites-enabled/image
```

### 重啟 Nginx 服務

```
service nginx restart
```

### 關於快取資料夾設定

```
proxy_cache_path  /var/nginx/cache/aws  levels=2:2:2 use_temp_path=off keys_zone=aws:2048m inactive=30d max_size=100g;
```

`config/image` 第一行設定是 proxy AWS S3 快取資料夾，預設為 `/var/nginx/cache/aws`，可以自訂義，修改之後一併要檢查系統有無此資料夾。

### 關於快取空間設定

```
keys_zone=aws:<cache size>
```

`cache size` 可自行設定，預設為 2048m，可依需求修改之。

## 架構與服務說明

本代理服務，透過 `nginx` Proxy Pass 功能代理與快取 AWS S3 檔案，提供 `Resize` 功能。

Client 可以透過代理服務取得 S3 的檔案，而代理伺服同時會將此檔案暫存快取，當 Client 再次請求相同的檔案，Nginx Cache 的機制會從快取中取得並回傳，進而節省對 S3 的請求流量，如果 Cliet 是以 Resize 的方式是請求，Resize 的服務則是向 Nginx Proxy 請求，而不是直接向 S3，主要也是透過希望透過快取方式來進行。

![S3-Proxy](file/S3-Proxy.jpg)

### 代理服務

原 AWS S3 Url：

```
<Protocol>://<AWS S3 Url>/<bucket>/85f38ab0-818f-11e7-a734-934facaaf741.jpeg
```

經 `nginx` 代理服務 Url：

```
<Protocol>://<Proxy Host>:<Port>/unsplash.iyp.tw/85f38ab0-818f-11e7-a734-934facaaf741.jpeg
```

### Resize 功能

設定寬度與高度，`nginx` 會透過參數進行處理，如果設定寬度與高度超過原圖片尺寸，Resize 功能將不會作動，反之，則會作動。

```
<Protocol>://<Proxy Host>:<Port>/resize/<width>x<height>/<bucket>/85f38ab0-818f-11e7-a734-934facaaf741.jpeg
```


