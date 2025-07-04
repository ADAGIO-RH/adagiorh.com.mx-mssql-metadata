USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblControlCalculoVariablesBimestrales](
	[IDControlCalculoVariables] [int] IDENTITY(1,1) NOT NULL,
	[Ejercicio] [int] NOT NULL,
	[IDRegPatronal] [int] NOT NULL,
	[IDBimestre] [int] NOT NULL,
	[Aplicar] [bit] NULL,
	[IDUsuario] [int] NOT NULL,
 CONSTRAINT [PK_NominaTblControlCalculoVariablesBimestrales_IDControlCalculoVariables] PRIMARY KEY CLUSTERED 
(
	[IDControlCalculoVariables] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_NominaTblControlCalculoVariablesBimestrales_Ejercicio_IDRegPatronal_IDBimestre] UNIQUE NONCLUSTERED 
(
	[Ejercicio] ASC,
	[IDRegPatronal] ASC,
	[IDBimestre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblControlCalculoVariablesBimestrales] ADD  CONSTRAINT [d_NominaTblControlCalculoVariablesBimestrales_Aplicar]  DEFAULT ((0)) FOR [Aplicar]
GO
ALTER TABLE [Nomina].[tblControlCalculoVariablesBimestrales]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatBimestres_NominaTblControlCalculoVariablesBimestrales_IDBimestre] FOREIGN KEY([IDBimestre])
REFERENCES [Nomina].[tblCatBimestres] ([IDBimestre])
GO
ALTER TABLE [Nomina].[tblControlCalculoVariablesBimestrales] CHECK CONSTRAINT [FK_NominaTblCatBimestres_NominaTblControlCalculoVariablesBimestrales_IDBimestre]
GO
ALTER TABLE [Nomina].[tblControlCalculoVariablesBimestrales]  WITH CHECK ADD  CONSTRAINT [Fk_NominatblControlCalculoVariablesBimestrales_SeguridadTblUsuarios_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Nomina].[tblControlCalculoVariablesBimestrales] CHECK CONSTRAINT [Fk_NominatblControlCalculoVariablesBimestrales_SeguridadTblUsuarios_IDUsuario]
GO
ALTER TABLE [Nomina].[tblControlCalculoVariablesBimestrales]  WITH CHECK ADD  CONSTRAINT [FK_RHTblCatRegPatronal_NominaTblControlCalculoVariablesBimestrales_IDRegPatronal] FOREIGN KEY([IDRegPatronal])
REFERENCES [RH].[tblCatRegPatronal] ([IDRegPatronal])
GO
ALTER TABLE [Nomina].[tblControlCalculoVariablesBimestrales] CHECK CONSTRAINT [FK_RHTblCatRegPatronal_NominaTblControlCalculoVariablesBimestrales_IDRegPatronal]
GO
