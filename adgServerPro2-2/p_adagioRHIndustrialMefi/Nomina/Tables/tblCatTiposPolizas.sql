USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Nomina].[tblCatTiposPolizas](
	[IDTipoPoliza] [int] NOT NULL,
	[Nombre] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaCreacion] [datetime] NOT NULL,
 CONSTRAINT [PK_NominaTblCatTiposPolizas_IDTipoPoliza] PRIMARY KEY CLUSTERED 
(
	[IDTipoPoliza] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Nomina].[tblCatTiposPolizas] ADD  CONSTRAINT [DF_NominaTblCatTiposPolizas_FechaCreacion]  DEFAULT (getdate()) FOR [FechaCreacion]
GO
ALTER TABLE [Nomina].[tblCatTiposPolizas]  WITH CHECK ADD  CONSTRAINT [Chk_NominaTblCatTiposPolizas_Descripcion] CHECK  ((isjson([Descripcion])=(1) OR [Descripcion] IS NULL))
GO
ALTER TABLE [Nomina].[tblCatTiposPolizas] CHECK CONSTRAINT [Chk_NominaTblCatTiposPolizas_Descripcion]
GO
ALTER TABLE [Nomina].[tblCatTiposPolizas]  WITH CHECK ADD  CONSTRAINT [Chk_NominaTblCatTiposPolizas_Nombre] CHECK  ((isjson([Nombre])=(1)))
GO
ALTER TABLE [Nomina].[tblCatTiposPolizas] CHECK CONSTRAINT [Chk_NominaTblCatTiposPolizas_Nombre]
GO
