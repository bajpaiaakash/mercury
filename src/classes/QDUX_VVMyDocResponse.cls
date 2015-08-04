/**
 * Created by: Eric Montelibano (PwC)- 21/05/2015
 * Application: Quality in Design User Experience (QDUX)
 * 
 * Description: JSON 2 APEX class that allows to deserialize JSON response. This allows Salesforce to read the JSON file.
 */
public class QDUX_VVMyDocResponse {
    public class Users {
    }
    
    public class Document {
        public Integer id;
        public Boolean binder;
        public Boolean allow_download_embedded_viewer;
        public Reviewer reviewer;
        public Reviewer viewer;
        public Reviewer distribution_contacts;
        public Reviewer consumer;
        public Reviewer approver;
        public Reviewer editor;
        public Owner owner;
        public Reviewer coordinator;
        public Boolean crosslink;
        public String lifecycle;
        public Integer version_created_by;
        public Integer minor_version_number;
        public Integer created_by;
        public Integer annotations_lines;
        public List<String> country;
        public String version_creation_date;
        public Boolean restrict_fragments_by_product;
        public Integer annotations_notes;
        public String version_modified_date;
        public String title;
        public Integer major_version_number;
        public Integer annotations_anchors;
        public List<String> product;
        public Integer annotations_resolved;
        public String type;
        public String status;
        public String document_creation_date;
        public Integer annotations_unresolved;
        public Boolean locked;
        public String document_number;
        public Integer annotations_links;
        public Integer annotations_all;
        public Integer last_modified_by;
        public String name;
        public String subtype;
    }
    
    public class Viewer {
        public List<Integer> users;
        public List<Long> groups;
    }
    
    public class Reviewer {
        public List<String> users;
        public List<String> groups;
    }
    
    public class Owner {
        public List<Integer> users;
        public List<String> groups;
    }
    
    public class Editor {
        public List<String> users;
        public List<Long> groups;
    }
    
    
    
    public String responseStatus;
    public Integer size;
    public Integer start;
    public Integer vlimit2;
    public List<Documents> documents;
    
    public class Documents {
        public Document document;
    }
    
    
    public static QDUX_VVMyDocResponse parse(String json) {
        return (QDUX_VVMyDocResponse) System.JSON.deserialize(json, QDUX_VVMyDocResponse.class);
    }
    public List<Errors> Errors;
    public class Errors{
        public string type;
        public string message;
    }
    
}