import { IExecuteFunctions, INodeExecutionData, INodeType, INodeTypeDescription } from "n8n-workflow";
export declare class DatabricksGenie implements INodeType {
    description: INodeTypeDescription;
    execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]>;
}
