function readTextFile()
{
    let result = '';
    var rawFile = new XMLHttpRequest();
    rawFile.open("GET", 'password', false);
    rawFile.onreadystatechange = function () {
        if(rawFile.readyState === 4) {
            if(rawFile.status === 200 || rawFile.status == 0) {
                result = rawFile.responseText;
            }
        }
    }
    rawFile.send(null);

    return result;
};

function readKeyFile()
{
    let result = '';
    var rawFile = new XMLHttpRequest();
    rawFile.open("GET", 'public-key', false);
    rawFile.onreadystatechange = function () {
        if(rawFile.readyState === 4) {
            if(rawFile.status === 200 || rawFile.status == 0) {
                result = rawFile.responseText;
            }
        }
    }
    rawFile.send(null);

    return result;
};


function redirectHome() {
    window.location.href = "index.html";
};

function promptPassword() {
    var password = prompt("비밀번호를 입력하세요:");
    if (password !== readTextFile()) {
      // 비밀번호가 틀렸을 때 실행할 코드
      alert('비밀번호가 일치하지 않습니다.');
      redirectHome();
    } 
};

function currentDate() {
    var currentDate = new Date();
    var year = currentDate.getFullYear();
    var month = String(currentDate.getMonth() + 1).padStart(2, '0');
    var day = String(currentDate.getDate()).padStart(2, '0');
    var hours = String(currentDate.getHours()).padStart(2, '0');
    var minutes = String(currentDate.getMinutes()).padStart(2, '0');
    var seconds = String(currentDate.getSeconds()).padStart(2, '0');

    return year + '-' + month + '-' + day + ' ' + hours + ':' + minutes + ':' + seconds;
}