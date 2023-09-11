# icc2017
#問題描述
距離變換(Distance Transform , DT)是一種應用在二值圖像處理的演算法，其運算結果為一灰階
圖像，此灰階圖像與一般灰階圖像不同，其灰階圖像強度並非表示亮度值，而是表示物件內部每一
點與物件邊緣的距離。
本題請完成一 Distance Transform 電路(後文以 DT 電路表示)，其輸入為一張二值化圖像(如圖
1.所式)，此二值化圖像存放於 Host 端的輸入圖像 ROM 模組(sti_ROM)中，DT 電路須從 Host 端的
sti_ROM 記憶體模組讀取二值化圖像資料，再對此圖像資料進行 distance transform 運算，運算後的
結果需寫入 Host 端的輸出結果圖像 RAM 模組(res_RAM)內，並在整張圖像處理完成後，將 done
訊號拉為 High，接著系統會比對整張圖像資料的正確性。

![image](https://github.com/Yuhua-Y/icc2017/assets/62470682/f38c9cda-49ac-4588-8b12-8ba5beac5ac2)
