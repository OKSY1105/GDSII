(globals
    version = 3
    io_order = default
)
(iopad
    (left
	(inst  name="u_pad_vddior_w"	cell="PADVDDIOR" )
	(inst  name="u_pad_vdd_w"	cell="PADVDD"    )
	(inst  name="u_pad_uart_rx"	cell="PADDI"     )
	(inst  name="u_pad_vss_w"	cell="PADVSS"    )
	(inst  name="u_pad_vssior_w"	cell="PADVSSIOR" )
    )
    (topleft
	(inst name="CORNER_TL" cell="padIORINGCORNER")
    )
    (top
	(inst  name="u_pad_vddior_n"	cell="PADVDDIOR" )
	(inst  name="u_pad_vdd_n"	cell="PADVDD"    )
	(inst  name="u_pad_vss_n"	cell="PADVSS"    )
	(inst  name="u_pad_vssior_n"	cell="PADVSSIOR" )
    )
    (topright
	(inst name="CORNER_TR" cell="padIORINGCORNER")
    )
    (right
	(inst  name="u_pad_vddior_e"	cell="PADVDDIOR" )
	(inst  name="u_pad_vdd_e"	cell="PADVDD"    )
	(inst  name="u_pad_uart_tx"	cell="PADDO"     )
	(inst  name="u_pad_vss_e"	cell="PADVSS"    )
	(inst  name="u_pad_vssior_e"	cell="PADVSSIOR" )
    )
    (bottomright
	(inst name="CORNER_BR" cell="padIORINGCORNER")
    )
    (bottom
	(inst  name="u_pad_vddior_s"	cell="PADVDDIOR" )
	(inst  name="u_pad_vdd_s"	cell="PADVDD"    )
	(inst  name="u_pad_vss_s"	cell="PADVSS"    )
	(inst  name="u_pad_vssior_s"	cell="PADVSSIOR" )
    )
    (bottomleft
	(inst name="CORNER_BL" cell="padIORINGCORNER")
    )
)
