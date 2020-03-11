/*
 * generated by Xtext 2.12.0
 */
package com.xatkit.language.execution.validation

import com.xatkit.common.CommonPackage
import com.xatkit.common.ImportDeclaration
import com.xatkit.utils.XatkitImportHelper
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.validation.Check

import static java.util.Objects.isNull
import org.eclipse.xtext.xbase.XMemberFeatureCall
import org.eclipse.xtext.xbase.XFeatureCall
import com.xatkit.language.execution.ExecutionUtils
import org.eclipse.xtext.xbase.XStringLiteral
import org.eclipse.xtext.xbase.XbasePackage
import org.eclipse.xtext.EcoreUtil2

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class ExecutionValidator extends AbstractExecutionValidator {

	@Check
	def checkImportDefinition(ImportDeclaration i) {
		val Resource importedResource = XatkitImportHelper.getInstance.getResourceFromImport(i)
		if (isNull(importedResource)) {
			error("Cannot resolve the import " + i.path, CommonPackage.Literals.IMPORT_DECLARATION__PATH)
		}
	}

	@Check
	def checkGetContext(XMemberFeatureCall f) {
		if (f.isStringGet) {
			if (f.targetIsContext) {
				val getKey = (f.memberCallArguments.get(0) as XStringLiteral).value
				val declaredContexts = ExecutionUtils.getEventDefinitionsFromImports(
					ExecutionUtils.getContainingExecutionModel(f)).flatMap[outContexts].map[name].toList
				if (!declaredContexts.contains(getKey)) {
					warning("Cannot find context " + getKey + " from the imported libraries/platforms.",
						XbasePackage.Literals.XMEMBER_FEATURE_CALL__MEMBER_CALL_ARGUMENTS)
				}
			}
		}
	}

	@Check
	def checkGetParameterOnContext(XMemberFeatureCall f) {
		if (f.isStringGet) {
			if (f.memberCallTarget instanceof XMemberFeatureCall) {
				val memberFeatureCallTarget = f.memberCallTarget as XMemberFeatureCall
				if (memberFeatureCallTarget.isStringGet && memberFeatureCallTarget.targetIsContext) {
					/*
					 * We are dealing with context.get.get here, we want to check that the parameter associated to the get key exists in the context.
					 */
					val getContextKey = (memberFeatureCallTarget.memberCallArguments.get(0) as XStringLiteral).value
					val getParameterKey = (f.memberCallArguments.get(0) as XStringLiteral).value
					if (ExecutionUtils.getEventDefinitionsFromImports(ExecutionUtils.getContainingExecutionModel(f)).
						flatMap[outContexts].filter [ c |
							c.name == getContextKey
						].flatMap[parameters].filter[p|p.name == getParameterKey].isEmpty) {
						/*
						 * Cannot find the parameter in the imported EventDefinition's contexts.
						 */
						warning("Cannot find the parameter " + getParameterKey + " in context " + getContextKey,
							XbasePackage.Literals.XMEMBER_FEATURE_CALL__MEMBER_CALL_ARGUMENTS)
					}
				}
			}
		}
	}

	@Check
	def checkGetSession(XMemberFeatureCall f) {
		if (f.isStringGet && f.targetIsSession) {
			val getKey = (f.memberCallArguments.get(0) as XStringLiteral).value
			val executionModel = ExecutionUtils.getContainingExecutionModel(f)
			val allMemberFeatureCalls = EcoreUtil2.eAllOfType(executionModel, XMemberFeatureCall)
			val putCallsWithSameKey = allMemberFeatureCalls.filter [ fCall |
				/*
				 * Look for a session.put call with the same key
				 */
				fCall.isPutWithStringKey && fCall.targetIsSession &&
					(fCall.memberCallArguments.get(0) as XStringLiteral).value == getKey
			]
			if (putCallsWithSameKey.empty) {
				warning("The session key " + getKey + " is not set in the execution model",
					XbasePackage.Literals.XMEMBER_FEATURE_CALL__MEMBER_CALL_ARGUMENTS)
			}
		}
	}

	private def boolean isStringGet(XMemberFeatureCall f) {
		return f.feature.simpleName == "get" && f.memberCallArguments.size == 1 &&
			f.memberCallArguments.get(0) instanceof XStringLiteral
	}

	private def boolean isPutWithStringKey(XMemberFeatureCall f) {
		return f.feature.simpleName == "put" && f.memberCallArguments.size == 2 &&
			f.memberCallArguments.get(0) instanceof XStringLiteral
	}

	private def boolean targetIsContext(XMemberFeatureCall f) {
		return f.memberCallTarget instanceof XFeatureCall &&
			(f.memberCallTarget as XFeatureCall).feature.simpleName == "context"
	}

	private def boolean targetIsSession(XMemberFeatureCall f) {
		return f.memberCallTarget instanceof XFeatureCall &&
			(f.memberCallTarget as XFeatureCall).feature.simpleName == "session"
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
