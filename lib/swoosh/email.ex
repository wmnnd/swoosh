defmodule Swoosh.Email do
 defstruct subject: nil, from: nil, to: nil, cc: nil, bcc: nil, text_body: nil,
           html_body: nil, attachments: nil
end
