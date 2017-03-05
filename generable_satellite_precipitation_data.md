# **水文气象研究中常用卫星降水数据产品汇总**
* 常用列表
* 下载方法
* 数据读取代码示例
***

![TRMM V7](https://disc.gsfc.nasa.gov/AIRS/images/3B42.20160229.7.png)
![cmorph](https://climatedataguide.ucar.edu/sites/default/files/styles/node_lightbox_display/public/key_figures/climate_data_set/CMORPH_1.png?itok=pKywo0zW)
|![GSmap](http://sharaku.eorc.jaxa.jp/GSMaP_crest/movie/GSMaP_MWR_monthly_anim.gif)
|![PRESIANN](http://climatology.ir/wp-content/uploads/2014/07/latest_6h3.gif)
|![IMERG](http://www.ncl.ucar.edu/Applications/Images/gpm_1_1_lg.png)

***
## **1.常用列表**
### **1.1不完全归纳汇总**
| list name | full name | spatial resolution | spatial coverage | Temporal resolution | Temporal span | reference |
|-----------|-----------|--------------------|---------------------|------------------|---------------|-----------|
|CHIRPS|Climate Hazards group Infrared Precipitation with Stations (CHIRPS)|0.05°×0.05°|50°N~50°S|Daily|1981~present|[Funk et al. (2015a)][1]|    
|CMORPH|CPC MORPHing technique (CMORPH)|0.25°×0.25°|60°N~60°S|Daily,3-houly|1998~present|[Joyce et al. (2004)][2]|
|GPCP-1DD|Global Precipitation Climatology Project (GPCP) 1-Degree Daily(1DD) Combination|1°×1°|Global|Daily|1996~2015|[Huffman et al. (2001)][3]|
|GSMaP-MVK|Global Satellite Mapping of Precipitation (GSMaP) Moving Vectorwith Kalman (MVK)|0.1°×0.1°|60°N~60°S|Hourly|2000~present|	[Iguchi et al. (2009)][4]|
|IMERG|Integrated Multi-satellitE Retrievals for GPM (IMERG)|0.1×0.1°|60°N~60°S|30 minutes|2014~present|[Huffman et al. (2014)][5]|
|PERSIANN|Precipitation Estimation from Remotely Sensed Information using ArtificialNeural Networks (PERSIANN)|0.25°×0.25°|60°N~60°S|3 hourly|2000.3~2015.2|[Sorooshian et al. (2000)][6]|
|TMPA 3B42|TRMM Multi-satellite Precipitation Analysis (TMPA) 3B42|0.25°×0.25°|50°N~50°S|3 hourly|1998~present|[Huffman et al. (2007)][7]|
|CHOMPS|Cooperative Institute for Climate Studies (CICS) High-Resolution Optimally Interpolated Microwave Precipitation from Satellites(CHOMPS)|	0.25°×0.25°|60°N~60°S|Daily|1998~2007|[Joseph et al. (2009)][8]|
|SM2RAIN-ASCAT|Based on Advanced Scatterometer (ASCAT) data (Brocca et al., 2016)|0.5°×0.5°|Global|	Daily|2007~2015|[Brocca et al. (2014)][9]|

### **1.2典型卫星降水产品基本信息（尽量下载nc和hdf格式）**
* **TMPA 3B42V7(TRMM Multi-satellite Precipitation Analysis (TMPA) 3B42)**

    [下载网址:ftp://disc2.nascom.nasa.gov/data/s4pa/TRMM_L3/](ftp://disc2.nascom.nasa.gov/data/s4pa/TRMM_L3/)

* **CMORPH(CPC MORPHing technique)**

    [下载地址：https://rda.ucar.edu/datasets/ds502.0/index.html#sfol-wl-/data/ds502.0?g=22002](https://rda.ucar.edu/datasets/ds502.0/index.html#sfol-wl-/data/ds502.0?g=22002)
    
    （注：需注册，公用账号请联系1145337525@qq.com）
* **GSMaP(Global Satellite Mapping of Precipitation)**

    [数据网址：http://sharaku.eorc.jaxa.jp/GSMaP/index.htm](http://sharaku.eorc.jaxa.jp/GSMaP/index.htm)

    （注：需注册，未尝试注册下载）

* **PERSIANN(PERSIANN CDR)**

    [下载地址:ftp://eclipse.ncdc.noaa.gov/pub/cdr/persiann/files/](ftp://eclipse.ncdc.noaa.gov/pub/cdr/persiann/files/)

    [备用地址：http://fire.eng.uci.edu/PERSIANN/adj_persiann_3hr.html](http://fire.eng.uci.edu/PERSIANN/adj_persiann_3hr.html)

* **IMERG()**
    
    [数据网址：https://pmm.nasa.gov/data-access/downloads/gpm](https://pmm.nasa.gov/data-access/downloads/gpm)

    （注：需注册）

    [辅助下载地址：https://gpm1.gesdisc.eosdis.nasa.gov/opendap/](https://gpm1.gesdisc.eosdis.nasa.gov/opendap/)

## **2.下载方法**

* (1) 以ftp://开头的网址，可直接利用ftp服务器工具下载，推荐[FillZilla: https://filezilla-project.org/](https://filezilla-project.org/)
* (2) 非ftp://站点，除数据网站提供的下载方法外，可以借助浏览器下载工具，下载整个页面的文件，推荐[firefox:https://www.mozilla.org/en-US/firefox/products/](https://www.mozilla.org/en-US/firefox/products/) + [DownThemall!:https://addons.mozilla.org/en-US/firefox/addon/downthemall/](https://addons.mozilla.org/en-US/firefox/addon/downthemall/)

## **3.常用数据格式读取**

* "nc格式"：

    matlab示例：ncread()函数
```
变量：
% filename：批量处理文件名
% minlon，maxlon：分别代表你所需区域的最小，最大经度范围，如[120E,130E]
% minlat,maxlat:  分别代表你所需区域的最小，最大维度范围
    lon=ncread(filename,'lon');%  longitude
    lat=ncread(filename,'lat');% lattitude
    time=ncread(filename,'time');% time
    a=find(lon()>=minlon & lon()<=maxlon);% 
    b=find(lat>=minlat & lat<=maxlat);% 
    a_E=lon(a); % 分别显示矩阵行列数对应经纬度,其为栅格中心坐标
    b_N=lat(b);
    lon_num=length(a);
    lat_num=length(b);
    time_num=length(time);
% 读取规定范围内的数据
    data=ncread(filename,'cmorph_precip',...
    [a(1) b(1) 1],[lon_num lat_num time_num]);
```
* "HDF格式"：

    matlab示例：hdfread()函数
```
for i=1:file_len
    filename=[TRMM_filename filelist(i).name]; 
    TRMM_DATA(:,:,i)= hdfread(filename,'/Grid/precipitation', 'Index',...
        {INDEX_start,INDEX_stride,INDEX_edge-INDEX_start});
end
```
* "HDF5格式"：

    参照matlab：hdf5read()函数

* "bin格式"：

    参照matlab：
```
% This program is to read a TRMM 3B42 daily binary file
read ".bin" folderstyle
fid = fopen('3B42_daily.2009.05.31.6.bin', 'r');
a = fread(fid, 'float','b');
fclose(fid);
data = a';
count = 1;
for i_lat = 1:400
    for j_lon = 1:1440
        lat = -49.875 + 0.25*(i_lat - 1);
        lon = -179.875 + 0.25*(j_lon - 1);
        daily_rain_total = data(count);
        count = count + 1;
    end
end
```

* 其他相关读取
  * "GSMaP数据"
        [相关网址：https://www.researchgate.net/post/How_can_I_read_JAXA_GSMaP_data](https://www.researchgate.net/post/How_can_I_read_JAXA_GSMaP_data)
  * "4-byte binary floatge格式"
    ```
    function om = loadbfn(fn,dim,sz)
    % loadbfn -- loads a binary file fn of dim 
    %       ([nrows ncols]) of sz 'float','int', etc.
    %
    %       by DKB on 2/5/96
    %
    if(nargin < 3)
        sz = 'float32';
    end
    f = fopen(fn,'r','l');
    if(nargout > 0)
        om = fread(f,flipud(dim(:))',sz)';
    end
    fclose(f); 
    ```

## **相关参考文献**
[1]Funk C, Peterson P, Landsfeld M, et al. The climate hazards infrared precipitation with stations--a new environmental record for monitoring extremes[J]. Scientific data, 2015, 2: 150066.

[2]Joyce R J, Janowiak J E, Arkin P A, et al. CMORPH: A method that produces global precipitation estimates from passive microwave and infrared data at high spatial and temporal resolution[J]. Journal of Hydrometeorology, 2004, 5(3): 487-503.

[3]Huffman G J, Adler R F, Morrissey M M, et al. Global precipitation at one-degree daily resolution from multisatellite observations[J]. Journal of Hydrometeorology, 2001, 2(1): 36-50.

[4]Ushio T, Sasashige K, Kubota T, et al. A Kalman filter approach to the Global Satellite Mapping of Precipitation (GSMaP) from combined passive microwave and infrared radiometric data[J]. Journal of the Meteorological Society of Japan. Ser. II, 2009, 87: 137-151.

[5]Huffman G J, Bolvin D T, Braithwaite D, et al. NASA Global Precipitation Measurement (GPM) Integrated Multi-Satellite Retrievals for GPM (IMERG) Algorithm Theoretical Basis Document (ATBD) Version 4.4[J]. 2014.

[6]Sorooshian S, Hsu K L, Gao X, et al. Evaluation of PERSIANN system satellite–based estimates of tropical rainfall[J]. Bulletin of the American Meteorological Society, 2000, 81(9): 2035-2046.

[7]Huffman G J, Bolvin D T, Nelkin E J, et al. The TRMM multisatellite precipitation analysis (TMPA): Quasi-global, multiyear, combined-sensor precipitation estimates at fine scales[J]. Journal of Hydrometeorology, 2007, 8(1): 38-55.

[8]Joseph R. CHOMPS: A new high resolution satellite derived precipitation data set for climate studies[C]//23rd Conference on Hydrology. 2009.

[9]Brocca,  L.,  Ciabatta,  L.,  Massari,  C.,  Moramarco,  T.,  Hahn,  S.,  Hasenauer,  S.,  Kidd,  R.,  Dorigo,  W., Wagner,  W.,  Levizzani,  V.  (2014).  Soil  as  a  natural  rain  gauge:  estimating global  rainfall  from satellite  soil  moisture  data.  Journal  of  Geophysical  Research,  119(9),  5128-5141, doi:10.1002/2014JD021489. 