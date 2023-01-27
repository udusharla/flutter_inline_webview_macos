function showAlert() {
    var i = 0;
    setInterval(function () {
        i++;
        const elem = document.getElementById('testDiv');
        elem.innerHTML = i;
    }, 1000 * 2);

}