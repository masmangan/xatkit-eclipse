/*
 * generated by Xtext 2.15.0
 */
package com.xatkit.language.execution.jvmmodel

import com.google.inject.Inject
import com.xatkit.execution.ExecutionModel
import com.xatkit.utils.ImportRegistry
import org.eclipse.xtext.common.types.JvmDeclaredType
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import com.xatkit.metamodels.utils.RuntimeModel

/**
 * <p>Infers a JVM model from the source model.</p> 
 * 
 * <p>The JVM model should contain all elements that would appear in the Java code 
 * which is generated from the source model. Other models link against the JVM model rather than the source model.</p>     
 */
class ExecutionJvmModelInferrer extends AbstractModelInferrer {

	/**
	 * convenience API to build and initialize JVM types and their members.
	 */
	@Inject extension JvmTypesBuilder

	public static String INFERRED_CLASS_NAME = "ExecutionModel"

	/**
	 * The dispatch method {@code infer} is called for each instance of the
	 * given element's type that is contained in a resource.
	 * 
	 * @param element
	 *            the model to create one or more
	 *            {@link JvmDeclaredType declared
	 *            types} from.
	 * @param acceptor
	 *            each created
	 *            {@link JvmDeclaredType type}
	 *            without a container should be passed to the acceptor in order
	 *            get attached to the current resource. The acceptor's
	 *            {@link IJvmDeclaredTypeAcceptor#accept(org.eclipse.xtext.common.types.JvmDeclaredType)
	 *            accept(..)} method takes the constructed empty type for the
	 *            pre-indexing phase. This one is further initialized in the
	 *            indexing phase using the lambda you pass as the last argument.
	 * @param isPreIndexingPhase
	 *            whether the method is called in a pre-indexing phase, i.e.
	 *            when the global index is not yet fully updated. You must not
	 *            rely on linking using the index if isPreIndexingPhase is
	 *            <code>true</code>.
	 */
	def dispatch void infer(ExecutionModel element, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
		/*
		 * Create the mock classes for Platform.Action(Params). These mocks are represented as static methods to match 
		 * the previous syntax. Note the the generated methods do not contain any execution logic, and are placeholders 
		 * that will be used by the interpreter to trigger the action computation.
		 */
		ImportRegistry.instance.getImportedPlatforms(element).forEach [ platform |
			acceptor.accept(platform.toClass(platform.name)) [
				platform.actions.forEach [ action |
					members += action.toMethod(action.name, typeRef(Object)) [
						/*
						 * If the parameter type / return type is not set we assume it is Object. This allows to support
						 * existing platforms without major refactoring.
						 */
						action.parameters.forEach [ parameter |
							parameters += parameter.toParameter(parameter.key, parameter.type ?: typeRef(Object))
						]
						returnType = action.returnType ?: typeRef(Object)
						static = true
						body = '''
							// This is a mock class, it shouldn't be called
							return null;
						'''
					]
				]
			]
		]
		/*
		 * Create the main class corresponding to the current execution model. This class contains methods for each 
		 * execution rule, and extends the RuntimeModel that provides additional fields to access context, session, and 
		 * configuration.
		 */
		acceptor.accept(element.toClass(INFERRED_CLASS_NAME)) [
			superTypes += typeRef(RuntimeModel)
			element.executionRules.forEach [ rule |
				members += rule.toMethod("executionRuleOn" + rule.event.name, typeRef(void)) [
					body = rule
				]
			]
		]
	}
}