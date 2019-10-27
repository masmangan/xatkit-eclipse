/*
 * generated by Xtext 2.12.0
 */
package com.xatkit.language.execution.validation

import com.xatkit.common.CommonPackage
import com.xatkit.common.ImportDeclaration
import com.xatkit.utils.ImportRegistry
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.validation.Check

import static java.util.Objects.isNull

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class ExecutionValidator extends AbstractExecutionValidator {

	@Check
	def checkImportDefinition(ImportDeclaration i) {
		val Resource importedResource = ImportRegistry.getInstance.getOrLoadImport(i)
		if(isNull(importedResource)) {
			error("Cannot resolve the import " + i.path, CommonPackage.Literals.IMPORT_DECLARATION__PATH)
		}
	}
//	
//	@Check
//	def checkDuplicatedAliases(ImportDeclaration i) {
//		val ExecutionModel executionModel = ExecutionUtils.getContainingExecutionModel(i)
//		executionModel.imports.forEach[executionModelImport | 
//			if(!executionModelImport.path.equals(i.path) && executionModelImport.alias.equals(i.alias)) {
//				error("Duplicated alias " + i.alias, CommonPackage.Literals.IMPORT_DECLARATION__ALIAS)
//			}
//		]
//	}

//	@Check
//	def checkValidContextAccess(ContextAccess contextAccess) {
//		val ExecutionModel executionModel = ExecutionUtils.getContainingExecutionModel(contextAccess)
//		var boolean found = ExecutionUtils.getOutContextsFromImports(executionModel).map[name].toSet.contains(
//			contextAccess.contextName)
//		if (!found) {
//			println("The context " + contextAccess.contextName + " is undefined")
//			error("The context " + contextAccess.contextName + " is undefined",
//				CommonPackage.Literals.CONTEXT_ACCESS__CONTEXT_NAME)
//		}
//	}
//
//	@Check
//	def checkValidContextParameterAccess(OperationCall operationCall) {
//		if (operationCall.source instanceof ContextAccess && operationCall.name.equals("get")) {
//			if (operationCall.args.size == 1) {
//				if (operationCall.args.get(0) instanceof StringLiteral) {
//					val ContextAccess contextAccess = operationCall.source as ContextAccess
//					val String arg = (operationCall.args.get(0) as StringLiteral).value
//					val ExecutionModel executionModel = ExecutionUtils.getContainingExecutionModel(operationCall)
//					var boolean found = ExecutionUtils.getOutContextsFromImports(executionModel).filter [
//						name.equals(contextAccess.contextName)
//					].map [parameters.map[name]].flatten.toSet.contains(arg)
//					if (!found) {
//						error("Parameter " + arg + " is not defined in context " + contextAccess.contextName,
//							CommonPackage.Literals.OPERATION_CALL__ARGS)
//					}
//				} else {
//					// do nothing, it may be a variable holding a name
//				}
//			} else {
//				error("The method get on a stored context accepts a single element of type String",
//					CommonPackage.Literals.OPERATION_CALL__ARGS)
//			}
//		}
//	}
}
