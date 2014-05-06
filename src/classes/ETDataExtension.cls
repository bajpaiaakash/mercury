public with sharing class ETDataExtension {
    public ETDataExtension() {}

    public ETDataExtension(String name, String des, String key) {
        this.dataExtensionName = name;
        this.description = des;
        this.key = key;

        this.isPublic = true;
        this.isSendable = true;
        this.isTestable = true;

        this.field = new List<Field>();
        this.retentionPolicy = new List<RetentionPolicy>();
        this.retentionPolicy.add(new RetentionPolicy(false, false, String.valueOf(Datetime.now().addDays(1)), false));
    }

    public String dataExtensionName;
    public String description;
    public List<Field> field;
    public Boolean isPublic;
    public Boolean isSendable;
    public Boolean isTestable;
    public String key;
    public List<RetentionPolicy> retentionPolicy;
    public String sendableDataExtensionField;

    public class Field {
        public String fieldName;
        public String fieldType;
        public Object id;
        public Boolean isPrimaryKey;
        public Boolean isTemplateField;
        public String length;
        public Boolean nullable;
        public Object scale;
    }

    public class RetentionPolicy {
        public RetentionPolicy(Boolean deleteAtEnd, Boolean resetOnImport, String until, Boolean rowBased) {
            this.DeleteAtEndOfRetentionPeriod = deleteAtEnd;
            this.ResetRetentionPeriodOnImport = resetOnImport;
            this.RetainUntil = until;
            this.RowBasedRetention = rowBased;
        }
        public Boolean DeleteAtEndOfRetentionPeriod;
        public Boolean ResetRetentionPeriodOnImport;
        public String RetainUntil;
        public Boolean RowBasedRetention;
    }

    public class DataExtensionResponse {
        public String id;
    }
}