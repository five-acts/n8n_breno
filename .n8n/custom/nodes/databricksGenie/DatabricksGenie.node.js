"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DatabricksGenie = void 0;
const n8n_workflow_1 = require("n8n-workflow");
class DatabricksGenie {
    constructor() {
        this.description = {
            displayName: 'Databricks Genie',
            name: 'databricksGenie',
            group: ['transform'],
            icon: 'file:databricks.svg',
            version: 1,
            description: 'Talk with Databricks Genie via API calls.',
            defaults: {
                name: 'Databricks Genie',
            },
            inputs: ["main"],
            outputs: ["main"],
            credentials: [
                {
                    name: 'databricksGenieApi',
                    required: true
                }
            ],
            properties: [
                {
                    displayName: 'Space ID',
                    name: 'spaceID',
                    type: 'string',
                    default: '',
                    description: 'Your Genie space ID. Its the last part of the URL when you enter the Genie chat interface - https://your-databricks-URL/genie/rooms/your-space-ID. THE SPACE ID ENDS RIGHT BEFORE THE QUESTION MARK (?) - DO NOT INCLUDE ANYTHING AFTER IT.',
                    placeholder: 'your-space-ID',
                    required: true
                },
                {
                    displayName: 'Message',
                    name: 'message',
                    type: 'string',
                    default: '',
                    description: 'The message you want to send to genie',
                    placeholder: 'What are my top 10 RCAs?',
                    required: true
                },
            ],
        };
    }
    async execute() {
        const spaceID = this.getNodeParameter('spaceID', 0);
        const message = this.getNodeParameter('message', 0);
        const credentials = await this.getCredentials('databricksGenieApi');
        let returnData = [];
        const startConversationOptions = {
            url: `${credentials.workspaceUrl}/api/2.0/genie/spaces/${spaceID}/start-conversation`,
            method: "POST",
            headers: {
                'Authorization': `Bearer ${credentials.bearerToken}`,
                'Content-Type': 'apllication/json'
            },
            body: {
                content: message,
            },
            json: true
        };
        const startConversationResponse = await this.helpers.httpRequest(startConversationOptions);
        const conversationId = startConversationResponse.message.conversation_id;
        const messageId = startConversationResponse.message.message_id;
        let getMessageResponse;
        let getMessageOptions;
        let isComplete = false;
        let maxRetries = 24;
        getMessageOptions = {
            method: 'GET',
            url: `${credentials.workspaceUrl}/api/2.0/genie/spaces/${spaceID}/conversations/${conversationId}/messages/${messageId}`,
            headers: {
                'Authorization': `Bearer ${credentials.bearerToken}`,
                'Content-Type': 'apllication/json'
            },
            json: true
        };
        for (let retry = 0; retry < maxRetries; retry++) {
            getMessageResponse = await this.helpers.httpRequest(getMessageOptions);
            if (getMessageResponse.status === "COMPLETED") {
                isComplete = true;
                break;
            }
            await new Promise(resolve => setTimeout(resolve, 5000));
        }
        if (!isComplete) {
            throw new n8n_workflow_1.NodeOperationError(this.getNode(), 'Genie timed out and did not send back a message.');
        }
        const genieResponse = getMessageResponse.description;
        let queryResult = {};
        if (getMessageResponse.attachments && getMessageResponse.attachments.length > 0) {
            const attachmentId = getMessageResponse.attachments[0].attachment_id;
            const getQueryResult = {
                method: 'GET',
                url: `${credentials.workspaceUrl}/api/2.0/genie/spaces/${spaceID}/conversations/${conversationId}/messages/${messageId}/attachments/${attachmentId}/query-result`,
                headers: {
                    'Authorization': `Bearer ${credentials.bearerToken}`,
                    'Content-Type': 'apllication/json'
                },
                json: true
            };
            queryResult = await this.helpers.httpRequest(getQueryResult);
        }
        returnData.push({
            json: {
                genieResponse,
                queryResult
            }
        });
        return [this.helpers.returnJsonArray(returnData)];
    }
}
exports.DatabricksGenie = DatabricksGenie;
//# sourceMappingURL=DatabricksGenie.node.js.map