function toggleLoading() {
	try {
		$("div.merc-loading").toggle()
		$(".loading-message-wrapper").css("top",(window.getScrollY()+50) + "px");
	} catch(e) {
		j("div.merc-loading").toggle()
	}
}

function escapeVfId(id) {
    return '#' + id.replace(/(:|\.)/g,'\\$1');
}