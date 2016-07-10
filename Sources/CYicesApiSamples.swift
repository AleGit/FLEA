import CYices

struct CYicesApiSamples {
		private static func status(context:OpaquePointer, term: term_t) {

			defer { print("-----------------------------------------------") } // print separator line after all output

			guard let string = String(term: term) else { return }
			print("assert", string)

			yices_assert_formula(context, term)

			switch (yices_check_context(context, nil)) {
				case STATUS_SAT:
					print("Satisfiable");

					// build the model and print it
					guard let mdl = yices_get_model(context, 1) else { return }
					defer { yices_free_model(mdl) }

					guard let model_string = String(model:mdl) else { return }
					print(model_string)
					break;

					case STATUS_UNSAT:
						print("Unsatisfiable");
						break;

						case STATUS_UNKNOWN:
							print("Status is unknown");
							break;

							case STATUS_IDLE:
								fallthrough
								case STATUS_SEARCHING:
									fallthrough
									case STATUS_INTERRUPTED:
										fallthrough
										case STATUS_ERROR:
											fallthrough
											default:
												// these codes should not be returned
												print("Bug: unexpected status returned");
												break;
											}
										}

										/// Constructs thre clauses:
										/// - a tautology
										/// - a positive literal clause `p(f(a,b),a,b)`
										/// - a negative literal clause
										/// an checks satisfiability.
										static func demo() {
											yices_init()
											defer { yices_exit() }

											guard let context = yices_new_context(nil) else { return }
											defer { yices_free_context(context) }

											let bool_tau = yices_bool_type()
											let free_tau = yices_int_type()

											// constant 'a'
											let a = yices_new_uninterpreted_term(free_tau)
											yices_set_term_name(a, "a")

											// constant 'b'
											let b = yices_new_uninterpreted_term(free_tau)
											yices_set_term_name(b, "b")

											// tpye '(free,free)->free'
											let f_domain = [type_t](repeating:free_tau, count:2)
											let f_tau = yices_function_type(UInt32(f_domain.count), f_domain, free_tau)
											let f = yices_new_uninterpreted_term(f_tau)
											yices_set_term_name(f, "f")

											// function 'f(a,b)'
											var args = [a,b]
											let fab = yices_application(f,UInt32(args.count), args)

											// type '(free,free,free)->bool'
											let p_domain = [ free_tau, free_tau, free_tau ]
											let p_tau = yices_function_type(UInt32(p_domain.count), p_domain, bool_tau)
											let p = yices_new_uninterpreted_term(p_tau)
											yices_set_term_name(p, "p")

											// predicate 'p(fab,a,b)'
											args = [fab,a,b]
											let pfab = yices_application(p,UInt32(args.count), args)

											// 'NOT p(fab,a,b)'
											let npfab = yices_not(pfab)
											// 'p(fab,a,b) OR NOT p(fab,a,b)'
											let tautology = yices_or2(pfab,npfab)

											status(context:context, term:tautology)
											status(context:context, term:pfab)
											status(context:context, term:npfab)
										}
									}
