USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatPlazas](
	[IDPlaza] [int] IDENTITY(1,1) NOT NULL,
	[IDCliente] [int] NOT NULL,
	[Codigo] [App].[SMName] NOT NULL,
	[ParentId] [int] NOT NULL,
	[TotalPosiciones] [int] NOT NULL,
	[PosicionesOcupadas] [int] NOT NULL,
	[PosicionesDisponibles] [int] NOT NULL,
	[Configuraciones] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDPuesto] [int] NOT NULL,
	[IDNivelSalarial] [int] NULL,
	[DescripcionPublicaVacante] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[EsAsistente] [bit] NULL,
	[IDOrganigrama] [int] NULL,
	[IDNivelEmpresarial] [int] NULL,
	[PosicionesCanceladas] [int] NULL,
 CONSTRAINT [Pk_RHTblCatPlazas_IDPlaza] PRIMARY KEY CLUSTERED 
(
	[IDPlaza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_RHTblCatPlazas_Codigo_IDOrganigrama] ON [RH].[tblCatPlazas]
(
	[Codigo] ASC,
	[IDOrganigrama] ASC
)
WHERE ([IDOrganigrama] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatPlazas] ADD  CONSTRAINT [D_RHTblCatPlazas_EsAsistente]  DEFAULT ((0)) FOR [EsAsistente]
GO
ALTER TABLE [RH].[tblCatPlazas]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatPlazas_RHCatPuestos_IDPuesto] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
GO
ALTER TABLE [RH].[tblCatPlazas] CHECK CONSTRAINT [FK_RHtblCatPlazas_RHCatPuestos_IDPuesto]
GO
ALTER TABLE [RH].[tblCatPlazas]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatPlazas_RHCatTblNivelesEmpresariales_IDNivelEmpresarial] FOREIGN KEY([IDNivelEmpresarial])
REFERENCES [RH].[tblCatNivelesEmpresariales] ([IDNivelEmpresarial])
GO
ALTER TABLE [RH].[tblCatPlazas] CHECK CONSTRAINT [FK_RHtblCatPlazas_RHCatTblNivelesEmpresariales_IDNivelEmpresarial]
GO
ALTER TABLE [RH].[tblCatPlazas]  WITH CHECK ADD  CONSTRAINT [FK_RHtblCatPlazas_RHtblCatOrganigramas_IDOrganigrama] FOREIGN KEY([IDOrganigrama])
REFERENCES [RH].[tblCatOrganigramas] ([IDOrganigrama])
GO
ALTER TABLE [RH].[tblCatPlazas] CHECK CONSTRAINT [FK_RHtblCatPlazas_RHtblCatOrganigramas_IDOrganigrama]
GO
