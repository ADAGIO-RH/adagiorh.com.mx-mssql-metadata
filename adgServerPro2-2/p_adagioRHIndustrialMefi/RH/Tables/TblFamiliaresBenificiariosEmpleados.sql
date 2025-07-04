USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[TblFamiliaresBenificiariosEmpleados](
	[IDFamiliarBenificiarioEmpleado] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpleado] [int] NOT NULL,
	[IDParentesco] [int] NOT NULL,
	[NombreCompleto] [varchar](500) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[FechaNacimiento] [date] NULL,
	[Sexo] [char](1) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TelefonoMovil] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[TelefonoCelular] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Emergencia] [bit] NULL,
	[Beneficiario] [bit] NULL,
	[Dependiente] [bit] NULL,
	[Porcentaje] [decimal](5, 2) NULL,
 CONSTRAINT [Pk_RHTblFamiliaresBenificiariosEmpleados_IDFamiliarBenificiarioEmpleado] PRIMARY KEY CLUSTERED 
(
	[IDFamiliarBenificiarioEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHTblFamiliaresBenificiariosEmpleados_IDEmpleado] ON [RH].[TblFamiliaresBenificiariosEmpleados]
(
	[IDEmpleado] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RHTblFamiliaresBenificiariosEmpleados_IDParentesco] ON [RH].[TblFamiliaresBenificiariosEmpleados]
(
	[IDParentesco] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[TblFamiliaresBenificiariosEmpleados] ADD  CONSTRAINT [Fk_RHTblFamiliaresBenificiariosEmpleados_Emergencia]  DEFAULT ((0)) FOR [Emergencia]
GO
ALTER TABLE [RH].[TblFamiliaresBenificiariosEmpleados] ADD  CONSTRAINT [Fk_RHTblFamiliaresBenificiariosEmpleados_Beneficiario]  DEFAULT ((0)) FOR [Beneficiario]
GO
ALTER TABLE [RH].[TblFamiliaresBenificiariosEmpleados] ADD  CONSTRAINT [Fk_RHTblFamiliaresBenificiariosEmpleados_Dependiente]  DEFAULT ((0)) FOR [Dependiente]
GO
ALTER TABLE [RH].[TblFamiliaresBenificiariosEmpleados] ADD  DEFAULT ((0)) FOR [Porcentaje]
GO
ALTER TABLE [RH].[TblFamiliaresBenificiariosEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblFamiliaresBenificiariosEmpleados_IDEmpleado] FOREIGN KEY([IDEmpleado])
REFERENCES [RH].[tblEmpleados] ([IDEmpleado])
ON DELETE CASCADE
GO
ALTER TABLE [RH].[TblFamiliaresBenificiariosEmpleados] CHECK CONSTRAINT [Fk_RHTblFamiliaresBenificiariosEmpleados_IDEmpleado]
GO
ALTER TABLE [RH].[TblFamiliaresBenificiariosEmpleados]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblFamiliaresBenificiariosEmpleados_IDParentesco] FOREIGN KEY([IDParentesco])
REFERENCES [RH].[TblCatParentescos] ([IDParentesco])
GO
ALTER TABLE [RH].[TblFamiliaresBenificiariosEmpleados] CHECK CONSTRAINT [Fk_RHTblFamiliaresBenificiariosEmpleados_IDParentesco]
GO
