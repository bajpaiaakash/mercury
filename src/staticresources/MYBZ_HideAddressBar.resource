function openWindow(){

    var window_dimensions = "toolbars=no,menubar=no,location=no,scrollbars=yes,resizable=yes,status=yes"  
    //window.opener=self 
    window.open("https://gso--deldev--c.cs18.visual.force.com/apex/Mobile_POC3_Index?Name=Neelam","_blank",  window_dimensions);  
    window.moveTo(0,0);  
    window.resizeTo(screen.width,screen.height-100);  
	window.close();
         }

          