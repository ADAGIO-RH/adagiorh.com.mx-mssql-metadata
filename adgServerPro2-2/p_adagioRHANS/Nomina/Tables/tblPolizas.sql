USE [p_adagioRHANS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblPolizas](
	[IDPoliza] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoPoliza] [int] NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Filtro] [varchar](255) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NOT NULL,
	[FechaCreacion] [datetime] NOT NULL,
 CONSTRAINT [PK_NominaTblPolizas_IDPoliza] PRIMARY KEY CLUSTERED 
(
	[IDPoliza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblPolizas] ADD  CONSTRAINT [DF_NominaTblPolizas_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Nomina].[tblPolizas]  WITH CHECK ADD  CONSTRAINT [FK_NominaTblCatTiposPolizas_NominaTblPolizas_IDTipoPoliza] FOREIGN KEY([IDTipoPoliza])
REFERENCES [Nomina].[tblCatTiposPolizas] ([IDTipoPoliza])
GO
ALTER TABLE [Nomina].[tblPolizas] CHECK CONSTRAINT [FK_NominaTblCatTiposPolizas_NominaTblPolizas_IDTipoPoliza]
GO
ALTER TABLE [Nomina].[tblPolizas]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblCatTiposFiltros_NominaTblPolizas_Filtro] FOREIGN KEY([Filtro])
REFERENCES [Seguridad].[tblCatTiposFiltros] ([Filtro])
GO
ALTER TABLE [Nomina].[tblPolizas] CHECK CONSTRAINT [FK_SeguridadTblCatTiposFiltros_NominaTblPolizas_Filtro]
GO
ALTER TABLE [Nomina].[tblPolizas]  WITH CHECK ADD  CONSTRAINT [FK_SeguridadTblUsuarios_NominaTblPolizas_IDUsuario] FOREIGN KEY([IDUsuario])
REFERENCES [Seguridad].[tblUsuarios] ([IDUsuario])
GO
ALTER TABLE [Nomina].[tblPolizas] CHECK CONSTRAINT [FK_SeguridadTblUsuarios_NominaTblPolizas_IDUsuario]
GO
