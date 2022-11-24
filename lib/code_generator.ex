defmodule CodeGenerator do
  def generate_code(ast) do
    code = post_order(ast)
    code
  end

  def post_order(node) do
    case node do
      nil ->
        nil

      ast_node ->
        code_snippet = post_order(ast_node.left_node)
        # TODO: Falta terminar de implementar cuando el arbol tiene mas ramas
        post_order(ast_node.right_node)
        emit_code(ast_node.node_name, ast_node.value, code_snippet)
    end
  end

  @spec emit_code(:constant | :function | :program | :return | :unary_operator, any, any) ::
          <<_::64, _::_*8>>
  def emit_code(:program, _, code_snippet) do
    """
        .section        .text
        .p2align        4, 0x90
    """ <>
      code_snippet
  end

  def emit_code(:function, :main, code_snippet) do
    """
        .globl  main         ## -- Begin function main
    main:                    ## @main
    """ <>
      code_snippet
  end

  def emit_code(:return, _, code_snippet) do
    code_snippet <>
    """
        ret
    """
  end

  def emit_code(:constant, value, _) do
    """
        movl    $#{value}, %eax
    """
  end

  def emit_code(:unary_operator, :negation, code_snippet) do
    code_snippet <>
    """
        neg     %eax
    """
  end

  def emit_code(:unary_operator, :bitwise_complement, code_snippet) do
    code_snippet <>
    """
        not     %eax
    """
  end

  def emit_code(:unary_operator, :logical_negation, code_snippet) do
    code_snippet <>
    """
        cmpl   $0, %eax
        movl   $0, %eax
        sete   %al
    """
  end
end
