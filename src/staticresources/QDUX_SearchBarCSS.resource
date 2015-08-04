/* CSS SET UP */

input.searchButton{
    background: #D3CCC8;
    font-size:18px;
    color:#D52B1E;
    font-family:DINWebPro-Bold;
    
}
input.searchButton:hover{
    background:#A59D95;
    background-position: 0 0;
    font-size:18px;
    color:#D52B1E;
    font-family:DINWebPro-Bold;
}

.searchText{
    width:50%; 
    height:50px; 
    border:1px solid; 
    border-radius: 5px; 
    padding-left:10px; 
    font-family: DINWebPro-Bold;
    font-size: 14px;
}

.box{
    
    width: 85%;
    height: 50px;
}

/* Search 1 - bg change*/
.container-1{
    width: 100%;
    vertical-align: middle;
    white-space: nowrap;
    position: relative;
}
.container-1 input.search{
    
    width: 75%;
    height: 50px;
    background: #F7819F;
    border: 1px solid;
    font-size: 10pt;
    float: left;
    color: #262626;
    padding-left: 45px;
    -webkit-border-radius: 5px;
    -moz-border-radius: 5px;
    border-radius: 5px;
    
    -webkit-transition: all .55s ease;
    -moz-transition: all .55s ease;
    -ms-transition: all .55s ease;
    -o-transition: all .55s ease;
    transition: all .55s ease;
}

.s1 {
    width: 300px;
    height: 50px;
    background: #2b303b;
    border: none;
    font-size: 10pt;
    float: left;
    color: #262626;
    padding-left: 45px;
    -webkit-border-radius: 5px;
    -moz-border-radius: 5px;
    border-radius: 5px;
    
    -webkit-transition: all .55s ease;
    -moz-transition: all .55s ease;
    -ms-transition: all .55s ease;
    -o-transition: all .55s ease;
    transition: all .55s ease;
}

.container-1 input.search::-webkit-input-placeholder {
    color: #65737e;
}
.container-1 input.search:-moz-placeholder { /* Firefox 18- */
    color: #65737e;  
}
.container-1 input.search::-moz-placeholder {  /* Firefox 19+ */
    color: #65737e;  
}
.container-1 input.search:-ms-input-placeholder {  
    color: #65737e;  
}

.container-1 .icon{
    position: absolute;
    top: 50%;
    margin-left: 17px;
    margin-top: 17px;
    z-index: 1;
    color: #4f5b66;
}

/* ANIMATION EFFECTS */
.container-1 input.search:focus, .container-1 input.search:active{
    outline:none;
    background: #ffffff;
}

