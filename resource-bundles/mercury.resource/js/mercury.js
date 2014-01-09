function toggleLoading() {
	try {
		$("div.merc-loading").toggle()
	} catch(e) {
		j("div.merc-loading").toggle()
	}
}

function escapeVfId(id) {
    return '#' + id.replace(/(:|\.)/g,'\\$1');
}