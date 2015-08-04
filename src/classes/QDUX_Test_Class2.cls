/**
 * Created by: Eric Montelibano (PwC)- 21/05/2015
 * Application: Quality in Design User Experience (QDUX)
 * 
 * Description: Test Methods for JSON 2 APEX  classes.
*/

@isTest
public class QDUX_Test_Class2 {
    //Task and Workflows
    static testMethod void testVVTask() {
		String json = '{'+
		'   \"responseStatus\": \"SUCCESS\",'+
		'   \"responseDetails\":    {'+
		'      \"limit\": 1000,'+
		'      \"offset\": 0,'+
		'      \"size\": 5,'+
		'      \"total\": 5'+
		'   },'+
		'   \"data\":    ['+
		'            {'+
		'         \"workflow_id__v\": 100280,'+
		'         \"workflow_status__v\": \"Active\",'+
		'         \"task_id__v\": 100309,'+
		'         \"task_name__v\": \"Review Task\",'+
		'         \"task_status__v\": \"Assigned\",'+
		'         \"task_assignee_name__v\": \"Eric Montelibano\",'+
		'         \"task_assignee__v\": 285309,'+
		'         \"task_dueDate__v\": \"2015-05-15\",'+
		'         \"workflow_document_id__v\": 105'+
		'      },'+
		'            {'+
		'         \"workflow_id__v\": 100311,'+
		'         \"workflow_status__v\": \"Active\",'+
		'         \"task_id__v\": 100362,'+
		'         \"task_name__v\": \"Assess Reviewer Comments Task\",'+
		'         \"task_status__v\": \"Assigned\",'+
		'         \"task_assignee_name__v\": \"Eric Montelibano\",'+
		'         \"task_assignee__v\": 285309,'+
		'         \"task_dueDate__v\": \"2015-05-19\",'+
		'         \"workflow_document_id__v\": 125'+
		'      },'+
		'            {'+
		'         \"workflow_id__v\": 100308,'+
		'         \"workflow_status__v\": \"Active\",'+
		'         \"task_id__v\": 100351,'+
		'         \"task_name__v\": \"Document Control Review\",'+
		'         \"task_status__v\": \"Assigned\",'+
		'         \"task_assignee_name__v\": \"Eric Montelibano\",'+
		'         \"task_assignee__v\": 285309,'+
		'         \"task_dueDate__v\": \"2015-05-19\",'+
		'         \"workflow_document_id__v\": 126'+
		'      },'+
		'            {'+
		'         \"workflow_id__v\": 100315,'+
		'         \"workflow_status__v\": \"Cancelled\",'+
		'         \"task_id__v\": 100384,'+
		'         \"task_name__v\": \"Document Control Review\",'+
		'         \"task_status__v\": \"Cancelled\",'+
		'         \"task_assignee_name__v\": \"Eric Montelibano\",'+
		'         \"task_assignee__v\": 285309,'+
		'         \"task_dueDate__v\": \"2015-05-20\",'+
		'         \"workflow_document_id__v\": 109'+
		'      },'+
		'            {'+
		'         \"workflow_id__v\": 100297,'+
		'         \"workflow_status__v\": \"Active\",'+
		'         \"task_id__v\": 100323,'+
		'         \"task_name__v\": \"Edit Task\",'+
		'         \"task_status__v\": \"Assigned\",'+
		'         \"task_assignee_name__v\": \"Eric Montelibano\",'+
		'         \"task_assignee__v\": 285309,'+
		'         \"task_dueDate__v\": \"2015-05-29\",'+
		'         \"workflow_document_id__v\": 110'+
		'      }'+
		'   ]'+
		'}';
		QDUX_VVMyDocResponse obj = QDUX_VVMyDocResponse.parse(json);
		System.assert(obj != null);
	}
    
    static testMethod void testVVSearchResult() {
		String json = '{'+
		'   \"responseStatus\": \"SUCCESS\",'+
		'   \"responseDetails\":    {'+
		'      \"limit\": 1000,'+
		'      \"offset\": 0,'+
		'      \"size\": 4,'+
		'      \"total\": 4'+
		'   },'+
		'   \"data\":    ['+
		'            {'+
		'         \"id\": 42,'+
		'         \"name__v\": \"flatfile\",'+
		'         \"title__v\": null,'+
		'         \"type__v\": \"SEQS\",'+
		'         \"subtype__v\": \"Safety\",'+
		'         \"status__v\": \"In Edit\",'+
		'         \"classification__v\": \"Resource\",'+
		'         \"lifecycle__v\": \"Draft to Effective Lifecycle\",'+
		'         \"country__v\": [\"unitedStates\"],'+
		'         \"owning_department__v\": [\"00D000000000201\"],'+
		'         \"document_impacted_audience1__cr\":          {'+
		'            \"responseDetails\":             {'+
		'               \"limit\": 250,'+
		'               \"offset\": 0,'+
		'               \"size\": 1,'+
		'               \"total\": 1'+
		'            },'+
		'            \"data\": [{\"name__v\": \"Business Systems\"}]'+
		'         },'+
		'         \"document_associated_standard1__cr\":          {'+
		'            \"responseDetails\":             {'+
		'               \"limit\": 250,'+
		'               \"offset\": 0,'+
		'               \"size\": 1,'+
		'               \"total\": 1'+
		'            },'+
		'            \"data\": [{\"name__v\": \"100\"}]'+
		'         },'+
		'         \"effective_date__v\": null,'+
		'         \"approved_date__vs\": null,'+
		'         \"document_number__v\": \"SEQS-000005\"'+
		'      },'+
		'            {'+
		'         \"id\": 43,'+
		'         \"name__v\": \"Clinical Template\",'+
		'         \"title__v\": null,'+
		'         \"type__v\": \"SEQS\",'+
		'         \"subtype__v\": \"Medical\",'+
		'         \"status__v\": \"In Edit\",'+
		'         \"classification__v\": \"Procedure\",'+
		'         \"lifecycle__v\": \"Draft to Effective Lifecycle\",'+
		'         \"country__v\": [\"unitedStates\"],'+
		'         \"owning_department__v\": [\"00D000000000201\"],'+
		'         \"document_impacted_audience1__cr\":          {'+
		'            \"responseDetails\":             {'+
		'               \"limit\": 250,'+
		'               \"offset\": 0,'+
		'               \"size\": 1,'+
		'               \"total\": 1'+
		'            },'+
		'            \"data\": [{\"name__v\": \"Business Systems\"}]'+
		'         },'+
		'         \"document_associated_standard1__cr\":          {'+
		'            \"responseDetails\":             {'+
		'               \"limit\": 250,'+
		'               \"offset\": 0,'+
		'               \"size\": 1,'+
		'               \"total\": 1'+
		'            },'+
		'            \"data\": [{\"name__v\": \"100\"}]'+
		'         },'+
		'         \"effective_date__v\": null,'+
		'         \"approved_date__vs\": null,'+
		'         \"document_number__v\": \"SEQS-000006\"'+
		'      },'+
		'            {'+
		'         \"id\": 49,'+
		'         \"name__v\": \"Clinical Template\",'+
		'         \"title__v\": null,'+
		'         \"type__v\": \"SEQS\",'+
		'         \"subtype__v\": \"Medical\",'+
		'         \"status__v\": \"In Edit\",'+
		'         \"classification__v\": \"Procedure\",'+
		'         \"lifecycle__v\": \"Draft to Effective Lifecycle\",'+
		'         \"country__v\": [\"australia\"],'+
		'         \"owning_department__v\": [\"00D000000000201\"],'+
		'         \"document_impacted_audience1__cr\":          {'+
		'            \"responseDetails\":             {'+
		'               \"limit\": 250,'+
		'               \"offset\": 0,'+
		'               \"size\": 1,'+
		'               \"total\": 1'+
		'            },'+
		'            \"data\": [{\"name__v\": \"Business Systems\"}]'+
		'         },'+
		'         \"document_associated_standard1__cr\":          {'+
		'            \"responseDetails\":             {'+
		'               \"limit\": 250,'+
		'               \"offset\": 0,'+
		'               \"size\": 1,'+
		'               \"total\": 1'+
		'            },'+
		'            \"data\": [{\"name__v\": \"400\"}]'+
		'         },'+
		'         \"effective_date__v\": null,'+
		'         \"approved_date__vs\": null,'+
		'         \"document_number__v\": \"SEQS-000011\"'+
		'      },'+
		'            {'+
		'         \"id\": 50,'+
		'         \"name__v\": \"test\",'+
		'         \"title__v\": \"test\",'+
		'         \"type__v\": \"SEQS\",'+
		'         \"subtype__v\": \"Medical\",'+
		'         \"status__v\": \"Draft\",'+
		'         \"classification__v\": \"Procedure\",'+
		'         \"lifecycle__v\": \"Draft to Effective Lifecycle\",'+
		'         \"country__v\":          ['+
		'            \"austria\",'+
		'            \"unitedStates\"'+
		'         ],'+
		'         \"owning_department__v\": [\"00D000000000201\"],'+
		'         \"document_impacted_audience1__cr\":          {'+
		'            \"responseDetails\":             {'+
		'               \"limit\": 250,'+
		'               \"offset\": 0,'+
		'               \"size\": 4,'+
		'               \"total\": 4'+
		'            },'+
		'            \"data\":             ['+
		'               {\"name__v\": \"CDIO\"},'+
		'               {\"name__v\": \"Clinical Data Flow and Technology\"},'+
		'               {\"name__v\": \"Business Systems\"},'+
		'               {\"name__v\": \"Clinical Innovation\"}'+
		'            ]'+
		'         },'+
		'         \"document_associated_standard1__cr\":          {'+
		'            \"responseDetails\":             {'+
		'               \"limit\": 250,'+
		'               \"offset\": 0,'+
		'               \"size\": 2,'+
		'               \"total\": 2'+
		'            },'+
		'            \"data\":             ['+
		'               {\"name__v\": \"100\"},'+
		'               {\"name__v\": \"400\"}'+
		'            ]'+
		'         },'+
		'         \"effective_date__v\": null,'+
		'         \"approved_date__vs\": null,'+
		'         \"document_number__v\": \"SEQS-000012\"'+
		'      }'+
		'   ]'+
		'}';
		QDUX_VVJSONSearchResultParser obj = QDUX_VVJSONSearchResultParser.parse(json);
		System.assert(obj != null);
	}

}