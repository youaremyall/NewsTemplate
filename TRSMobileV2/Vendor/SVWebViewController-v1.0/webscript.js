//Needs refactoring

var script = new function() {
    
    this.getElement = function(x,y) {
        
        return getLink(x,y);
    }

    getLink = function(x,y) {
        var tags = "";
        var e = "";
        var channelId = "";
        var docId = "";
        var url = "";
        var result = "";
        var offset = 0;
        while ((tags.length == 0) && (offset < 5)) {
            e = document.elementFromPoint(x,y+offset);
            while (e) {
                if (e.href) {
                    if(e.getAttribute('channelId')){channelId= e.getAttribute('channelId');}
                    if(e.getAttribute('docid')){docId= e.getAttribute('docid');}
                    
                    url = e.href;
                    result =  '{"type" : "link" , "url" : "' + url + '" , "channelId" : "'+ channelId +'", "docid" : "'+ docId +'"}';
                    break;
                }
                e = e.parentNode;
            }
            offset++;
        }
        if (result != null && result.length > 0 && (channelId != "" && docid != "") ){
            return result;
        }
        else {
            return getImage(x, y);
        }
    }
    
    getImage = function(x,y) {
        var tags = "";
        var title = "";
        var e = "";
        var offset = 0;
        while ((tags.length == 0) && (offset < 20)) {
            e = document.elementFromPoint(x,y+offset);
            while (e) {
                if (e.src) {
                    tags += e.src;
                    title += e.alt;
                    break;
                }
                e = e.parentNode;
            }
            if (tags.length == 0) {
                e = document.elementFromPoint(x,y-offset);
                while (e) {
                    if (e.src) {
                        tags += e.src;
                        title += e.alt;
                        break;
                    }
                    e = e.parentNode;
                }
            }
            offset++;
        }
        
        if (tags != null && tags.length > 0) return '{ "type" : "image" , "url" : "'+ tags +'" , "title" : "'+ title +'"}';
        else return null;
    }
}