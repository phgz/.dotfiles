import { BaseConfig, ConfigArguments } from "jsr:@shougo/ddc-vim/config";

export class Config extends BaseConfig {
  override config(args: ConfigArguments): Promise<void> {
    args.contextBuilder.patchGlobal({
      ui: "inline",
      sources: ["lsp", "around"],
      autoCompleteEvents: [
        "InsertEnter",
        "TextChangedI",
        "TextChangedP",
      ],
      sourceOptions: {
        _: {
          matchers: ["matcher_fuzzy"],
          converters: ["converter_remove_overlap"],
          minAutoCompleteLength : 1,
        },
        around: {
          enabledIf: "luaeval('vim.tbl_count(vim.lsp.get_clients()) == 0')",
        },
        lsp: {
          forceCompletionPattern: "\\.\\w*|::\\w*|->\\w*",
          sorters: ["sorter_lsp-kind"],
          dup: "force",
        },
      },
      sourceParams: {
        lsp: {
          enableResolveItem: true,
          enableAdditionalTextEdit: true,
        },
            },
      postFilters:["sorter_fuzzy"],
      filterParams: {
        matcher_fuzzy: {
          splitMode: "word",
        },
        "sorter_lsp-kind": {
          priority: [["Variable", "Text", "Method", "Function"]]
        },
      },
      uiParams: {
          inline: {
            highlight : "NonText"
          },
      },
      backspaceCompletion: true,
    });
  }
}
