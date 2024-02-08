
;1. nhờ chatgpt tạo "tự động di chuyển chuột và click khi ấn nút x từ bán phím"
;2. hỏi nó viết lại thành 1 vòng lặp để sử dụng nhiều lần cái đã hỏi ở số 1.
;3. bạn muốn tạo nhiều hơn hay ít lại thì chỉ cần paste cái code đó vào chatgpt và chat bên dưới "tôi muốn lặp X lần".


count := 0
X::
count++
if (count = 1) {
  MouseMove, 500, 500
  Click, left
} else if (count = 2) {
  MouseMove, 700, 700
  Click, left
} else if (count = 3) {
  MouseMove, 900, 300
  Click, left
} else if (count = 4) {
  MouseMove, 200, 900
  Click, left
  count := 0
}
return