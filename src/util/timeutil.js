function getTime(date) {
    function btf(inp) {
    	if (inp < 10)
	    return "0" + inp;
    	return inp;
    }
    if (!date)
        date = new Date()
    var y = date.getFullYear(),
        m = btf(date.getMonth() + 1),
	    d = btf(date.getDate()),
	    h = btf(date.getHours()),
	    min = btf(date.getMinutes()),
        s = btf(date.getSeconds());
    return `${y}/${m}/${d} - ${h}:${min}:${s}`;
}

exports.getTime = getTime