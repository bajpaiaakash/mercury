public class ieCompatibility {

    public ieCompatibility() {
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=Edge'); 
    }
}