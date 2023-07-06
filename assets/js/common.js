function readTextFile()
{
    let result = '';
    var rawFile = new XMLHttpRequest();
    rawFile.open("GET", 'password', false);
    rawFile.onreadystatechange = function ()
    {
        if(rawFile.readyState === 4)
        {
            if(rawFile.status === 200 || rawFile.status == 0)
            {
                //return rawFile.responseText;
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