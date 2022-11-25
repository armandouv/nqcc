defmodule Parser do
  def parse_program(token_list) do
    if not Nqcc.is_error(token_list) do
      parse_program_safe(token_list)
    else
      token_list
    end
  end

  def parse_program_safe(token_list) do
    function = parse_function(token_list)

    result = case function do
      {{:parsing_error, error_type, error_message}, _rest} ->
        {:parsing_error, error_type, error_message}

      {function_node, rest} ->
        if rest == [] do
          %AST{node_name: :program, left_node: function_node}
        else
          {:parsing_error, :elements_after_end, "Error: there are more elements after function end"}
        end
    end

    case result do
      {:parsing_error, _error_type, error_message} ->
        IO.puts(error_message)
      _ -> result
    end

    result
  end

  def parse_function([next_token | rest]) do
    if next_token == :int_keyword do
      [next_token | rest] = rest

      if next_token == :main_keyword do
        [next_token | rest] = rest

        if next_token == :open_paren do
          [next_token | rest] = rest

          if next_token == :close_paren do
            [next_token | rest] = rest

            if next_token == :open_brace do
              statement = parse_statement(rest)

              case statement do
                {{:parsing_error, _error_type, _error_message}, _rest} ->
                  statement

                {statement_node, [:close_brace | rest]} ->
                  {%AST{node_name: :function, value: :main, left_node: statement_node}, rest}

                {_statement_node, remaining_tokens} -> {{:parsing_error, :close_brace_missed, "Error: close brace missed"}, remaining_tokens}
              end
            else
              {{:parsing_error, :open_brace_missed, "Error: open brace missed"}, rest}
            end
          else
            {{:parsing_error, :close_paren_missed, "Error: close parenthesis missed"}, rest}
          end
        else
          {{:parsing_error, :open_paren_missed, "Error: open parenthesis missed"}, rest}
        end
      else
        {{:parsing_error, :main_function_missed, "Error: main function missed"}, rest}
      end
    else
      {{:parsing_error, :return_type_missed, "Error: return type value missed"}, rest}
    end
  end

  def parse_statement([next_token | rest]) do
    if next_token == :return_keyword do
      expression = parse_expression(rest)

      case expression do
        {{:parsing_error, _error_type, _error_message}, _rest} ->
          expression

        {exp_node, [next_token | rest]} ->
          if next_token == :semicolon do
            {%AST{node_name: :return, left_node: exp_node}, rest}
          else
            {{:parsing_error, :return_semicolon_missed, "Error: semicolon missed after constant to finish return statement"}, rest}
          end
      end
    else
      {{:parsing_error, :return_missed, "Error: return keyword missed"}, rest}
    end
  end

  def parse_expression(tokens) do
    parse_production(tokens, [:or], &parse_logical_and_exp/1)
  end

  def parse_logical_and_exp(tokens) do
    parse_production(tokens, [:and], &parse_equality_exp/1)
  end

  def parse_equality_exp(tokens) do
    parse_production(tokens, [:equal, :not_equal], &parse_relational_exp/1)
  end

  def parse_relational_exp(tokens) do
    parse_production(tokens, [:less_than, :less_than_or_equal, :greater_than, :greater_than_or_equal], &parse_additive_exp/1)
  end

  def parse_additive_exp(tokens) do
    parse_production(tokens, [:addition, :negation], &parse_term/1)
  end

  def parse_term(tokens) do
    parse_production(tokens, [:multiplication, :division], &parse_factor/1)
  end

  def parse_factor([next_token | rest]) do
    factor = case next_token do
      :open_paren ->
        result = parse_expression(rest)
        case result do
          {{:parsing_error, _, _}, _rest} -> result
          {inner_exp_node, [:close_paren | after_paren]} -> {inner_exp_node, after_paren}
          {_inner_exp_node, rest_exp} -> {{:parsing_error, :closing_paren_missed, "Error: closing parenthesis missed"}, rest_exp}
        end

      {:constant, value} -> {%AST{node_name: :constant, value: value}, rest}

      next_token when next_token in [:negation, :logical_negation, :bitwise_complement] ->
        result = parse_factor(rest)
        case result do
          {{:parsing_error, _, _}, _rest} -> result
          {inner_exp_node, remaining} ->
            {%AST{node_name: :unary_operator, value: next_token, left_node: inner_exp_node}, remaining}
        end

        _ -> {{:parsing_error, :constant_missed, "Error: constant value missed"}, rest}
    end

    factor
  end

  def parse_production(tokens, operator_tokens, parse_operand) do
    operand = parse_operand.(tokens)

    final_operand = case operand do
      {{:parsing_error, _, _}, _rest} -> operand

      {_operand_node, _remaining_tokens} -> parse_loop(operand, operator_tokens, parse_operand)
    end

    final_operand
  end

  def parse_loop(left_operand, operator_tokens, parse_operand) do
    {left_operand_node, [next_token | rest]} = left_operand

    if (next_token in operator_tokens) do
      operand = parse_operand.(rest)

      case operand do
        {{:parsing_error, _, _}, _rest} -> operand

        {next_operand_node, next_operand_rest} ->
          new_left = {%AST{node_name: :binary_operator, value: next_token, left_node: left_operand_node, right_node: next_operand_node}, next_operand_rest}
          parse_loop(new_left, operator_tokens, parse_operand)
      end

    else
      {left_operand_node, [next_token | rest]}
    end
  end
end
