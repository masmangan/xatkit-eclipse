/*
 * generated by Xtext 2.12.0
 */
package com.xatkit.language.execution.ui.quickfix

import com.xatkit.language.execution.validation.ExecutionValidator
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.validation.Issue
import org.eclipse.xtext.ui.editor.model.edit.ISemanticModification
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext
import com.xatkit.execution.State
import com.xatkit.execution.ExecutionPackage
import com.xatkit.execution.Transition
import org.eclipse.xtext.ui.editor.model.edit.IModification
import com.xatkit.execution.ExecutionModel
import com.xatkit.execution.ExecutionFactory
import com.xatkit.language.execution.ExecutionLinkingDiagnosticMessageProvider

/**
 * Custom quickfixes.
 * 
 * See https://www.eclipse.org/Xtext/documentation/310_eclipse_support.html#quick-fixes
 */
class ExecutionQuickfixProvider extends DefaultQuickfixProvider {

	@Fix(ExecutionLinkingDiagnosticMessageProvider.STATE_NOT_RESOLVED)
	def createState(Issue issue, IssueResolutionAcceptor acceptor) {
		super.createLinkingIssueResolutions(issue, acceptor);
		val String missingState = issue.data?.get(0) ?: ""
		acceptor.accept(issue, 'Create State ' + missingState, 'Create a new State ' + missingState, '',
			new ISemanticModification() {
				
				override apply(EObject element, IModificationContext context) throws Exception {
					if(element instanceof Transition) {
						val parentState = element.eContainer as State
						val executionModel = parentState.eContainer as ExecutionModel
						val parentStateIndex = executionModel.states.indexOf(parentState)
						val newState = ExecutionFactory.eINSTANCE.createState
						newState.name = missingState
						executionModel.states.add(parentStateIndex + 1, newState)
					}
				}
			}
		)
	}

	@Fix(ExecutionValidator.TRANSITION_TO_DEFAULT_FALLBACK)
	@Fix(ExecutionValidator.CUSTOM_TRANSITION_SIBLING_IS_WILDCARD)
	def removeCustomTransition(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove custom transition', 'Remove the custom transition from the state', '',
			new ISemanticModification() {

				override apply(EObject element, IModificationContext context) throws Exception {
					val containingState = element.eContainer as State
					containingState.transitions.remove(element)
				}
			})
	}

	@Fix(ExecutionValidator.CUSTOM_TRANSITION_SIBLING_IS_WILDCARD)
	@Fix(ExecutionValidator.WILDCARD_TRANSITION_HAS_SIBLINGS)
	def removeWildcardTransition(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove wildcard transition', 'Remove the wildcard transition from the state', '',
			new ISemanticModification() {

				override apply(EObject element, IModificationContext context) throws Exception {
					val transition = element as Transition
					val containingState = element.eContainer as State
					if (transition.isWildcard) {
						/*
						 * The transition is a wildcard, we can just remove it
						 */
						containingState.transitions.remove(transition)
					} else {
						/*
						 * The transition is a custom transition (the user clicked the quick fix on the custom and not the wildcard), we look for all wildcard transitions and we delete them
						 */
						containingState.transitions.removeIf[it.isIsWildcard]
					}
				}
			})
	}

	@Fix(ExecutionValidator.WILDCARD_TRANSITION_HAS_SIBLINGS)
	def removeAllCustomTransitions(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove all custom transitions', 'Remove all the custom transitions from the state', '',
			new ISemanticModification() {

				override apply(EObject element, IModificationContext context) throws Exception {
					val containingState = element.eContainer as State
					containingState.transitions.removeIf[!it.isIsWildcard]
				}
			})
	}

	@Fix(ExecutionValidator.FALLBACK_SHOULD_NOT_EXIST)
	def removeFallback(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove Fallback', 'Remove the Fallback section from the state', '',
			new ISemanticModification() {

				override apply(EObject element, IModificationContext context) throws Exception {
					val state = element as State
					state.eUnset(ExecutionPackage.Literals.STATE__FALLBACK)
				}
			})
	}
	
	@Fix(ExecutionValidator.TRANSITIONS_SHOULD_NOT_EXIST)
	def removeTransitions(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Remove Transitions', 'Remove all the transitions from the state', '',
			new ISemanticModification() {
				
				override apply(EObject element, IModificationContext context) throws Exception {
					val state = element as State
					state.transitions.clear()
				}
			}
		)
	}
	
	@Fix(ExecutionValidator.INIT_STATE_DOES_NOT_EXIST)
	def addInitState(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Create Init State', 'Create the Init state', '',
			new ISemanticModification() {
				
				override apply(EObject element, IModificationContext context) throws Exception {
					val executionModel = element as ExecutionModel
					val initState = ExecutionFactory.eINSTANCE.createState
					initState.name = "Init"
					executionModel.states.add(0, initState)
				}
			}
		)
	}
	
	@Fix(ExecutionValidator.FALLBACK_STATE_DOES_NOT_EXIST)
	def addFallbackState(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, 'Create Default_Fallback State', 'Create the default fallback state', '',
			new ISemanticModification() {
				
				override apply(EObject element, IModificationContext context) throws Exception {
					val executionModel = element as ExecutionModel
					val fallbackState = ExecutionFactory.eINSTANCE.createState
					fallbackState.name = "Default_Fallback"
					executionModel.states.add(fallbackState)
				}
				
			}
		)
	}

}
