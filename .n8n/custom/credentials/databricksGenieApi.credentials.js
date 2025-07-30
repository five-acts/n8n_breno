"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.databricksGenieApi = void 0;
class databricksGenieApi {
    constructor() {
        this.name = 'databricksGenieApi';
        this.displayName = "Databricks Genie API";
        this.documentationUrl = 'https://example.com/docs/auth';
        this.properties = [
            {
                displayName: 'Workspace URL',
                name: 'workspaceUrl',
                type: 'string',
                default: '',
                placeholder: 'https://your-workspace-instance.databricks.com',
                description: 'Your databricks instance (first portion of URL, from the start to (...).databicks.com - Do not include the last dash (/)).'
            },
            {
                displayName: 'Bearer Token',
                name: 'bearerToken',
                type: 'string',
                default: '',
                description: 'Your databricks bearer token',
                typeOptions: {
                    password: true
                }
            }
        ];
    }
}
exports.databricksGenieApi = databricksGenieApi;
//# sourceMappingURL=databricksGenieApi.credentials.js.map