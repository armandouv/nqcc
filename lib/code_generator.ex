defmodule CodeGenerator do
  def generate_code(ast) do
    {code, _} = post_order(ast, 0)
    code
  end

  def post_order(node, label_number) do
    case node do
      nil ->
        {nil, label_number}

      ast_node ->
        {left_code_snippet, left_label_number} = post_order(ast_node.left_node, label_number)
        # TODO: Falta terminar de implementar cuando el arbol tiene mas ramas
        {right_code_snippet, new_label_number} = post_order(ast_node.right_node, left_label_number)

        if right_code_snippet == nil do
          {emit_code(ast_node.node_name, ast_node.value, left_code_snippet), new_label_number}
        else
          if ast_node.value in [:or, :and] do
            {emit_code(ast_node.node_name, ast_node.value, left_code_snippet, right_code_snippet, new_label_number),
            new_label_number + 1}
          else
            {emit_code(ast_node.node_name, ast_node.value, left_code_snippet, right_code_snippet), new_label_number}
          end
        end

    end
  end

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

  def emit_code(:binary_operator, :negation, left_code_snippet, right_code_snippet) do
    right_code_snippet <>
    """
        push   %rax
    """
    <> left_code_snippet <>
    """
        pop    %rcx
        subl   %ecx, %eax
    """
  end

  def emit_code(:binary_operator, :addition, left_code_snippet, right_code_snippet) do
    left_code_snippet <>
    """
        push   %rax
    """
    <> right_code_snippet <>
    """
        pop    %rcx
        addl   %ecx, %eax
    """
  end

  def emit_code(:binary_operator, :multiplication, left_code_snippet, right_code_snippet) do
    left_code_snippet <>
    """
        push   %rax
    """
    <> right_code_snippet <>
    """
        pop    %rcx
        imul   %ecx, %eax
    """
  end

  def emit_code(:binary_operator, :division, left_code_snippet, right_code_snippet) do
    right_code_snippet <>
    """
        push   %rax
    """
    <> left_code_snippet <>
    """
        cdq
        pop    %rcx
        idivl   %ecx
    """
  end

  def emit_code(:binary_operator, :equal, left_code_snippet, right_code_snippet) do
    left_code_snippet <>
    """
        push   %rax
    """
    <> right_code_snippet <>
    """
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        sete   %al
    """
  end

  def emit_code(:binary_operator, :not_equal, left_code_snippet, right_code_snippet) do
    left_code_snippet <>
    """
        push   %rax
    """
    <> right_code_snippet <>
    """
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        setne   %al
    """
  end

  def emit_code(:binary_operator, :less_than, left_code_snippet, right_code_snippet) do
    left_code_snippet <>
    """
        push   %rax
    """
    <> right_code_snippet <>
    """
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        setl   %al
    """
  end

  def emit_code(:binary_operator, :less_than_or_equal, left_code_snippet, right_code_snippet) do
    left_code_snippet <>
    """
        push   %rax
    """
    <> right_code_snippet <>
    """
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        setle   %al
    """
  end

  def emit_code(:binary_operator, :greater_than, left_code_snippet, right_code_snippet) do
    left_code_snippet <>
    """
        push   %rax
    """
    <> right_code_snippet <>
    """
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        setg   %al
    """
  end

  def emit_code(:binary_operator, :greater_than_or_equal, left_code_snippet, right_code_snippet) do
    left_code_snippet <>
    """
        push   %rax
    """
    <> right_code_snippet <>
    """
        pop    %rcx
        cmpl   %eax, %ecx
        movl   $0, %eax
        setge   %al
    """
  end

  def emit_code(:binary_operator, :and, left_code_snippet, right_code_snippet, label_number) do
    clause_label = "clause" <> Integer.to_string(label_number)
    end_label = "end" <> Integer.to_string(label_number)

    left_code_snippet <>
    """
        cmpl $0, %eax
        jne #{clause_label}
        jmp #{end_label}
    #{clause_label}:
    """
    <> right_code_snippet <>
    """
        cmpl $0, %eax
        movl $0, %eax
        setne %al
    #{end_label}:
    """
  end

  def emit_code(:binary_operator, :or, left_code_snippet, right_code_snippet, label_number) do
    clause_label = "clause" <> Integer.to_string(label_number)
    end_label = "end" <> Integer.to_string(label_number)

    left_code_snippet <>
    """
        cmpl $0, %eax
        je #{clause_label}
        movl $1, %eax
        jmp #{end_label}
    #{clause_label}:
    """
    <> right_code_snippet <>
    """
        cmpl $0, %eax
        movl $0, %eax
        setne %al
    #{end_label}:
    """
  end

end
