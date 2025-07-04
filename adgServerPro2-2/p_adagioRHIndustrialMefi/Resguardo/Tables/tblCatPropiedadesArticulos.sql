USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Resguardo].[tblCatPropiedadesArticulos](
	[IDPropiedad] [int] IDENTITY(1,1) NOT NULL,
	[TipoReferencia] [int] NOT NULL,
	[IDReferencia] [int] NOT NULL,
	[FechaHora] [datetime] NULL,
	[IDTipoPropiedad] [int] NOT NULL,
	[Nombre] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Varios] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[CopiadaDelIDPropiedad] [int] NULL,
	[Valor] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk__ResguardoTblCatPropiedadesArticulos_IDPropiedad] PRIMARY KEY CLUSTERED 
(
	[IDPropiedad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Resguardo].[tblCatPropiedadesArticulos] ADD  CONSTRAINT [D_ResguardoTblCatPropiedadesArticulos_TipoReferencia]  DEFAULT ((0)) FOR [TipoReferencia]
GO
ALTER TABLE [Resguardo].[tblCatPropiedadesArticulos] ADD  CONSTRAINT [D_ResguardoTblCatPropiedadesArticulos_FechaHora]  DEFAULT (getdate()) FOR [FechaHora]
GO
ALTER TABLE [Resguardo].[tblCatPropiedadesArticulos] ADD  CONSTRAINT [D_ResguardoTblCatPropiedadesArticulos_CopiadaDelIDPropiedad]  DEFAULT ((0)) FOR [CopiadaDelIDPropiedad]
GO
ALTER TABLE [Resguardo].[tblCatPropiedadesArticulos]  WITH CHECK ADD  CONSTRAINT [Fk_ResguardoTblCatPropiedadesArticulos_ResguardoTblCatTiposPropiedades_IDTipoPropiedad] FOREIGN KEY([IDTipoPropiedad])
REFERENCES [Resguardo].[tblCatTiposPropiedades] ([IDTipoPropiedad])
GO
ALTER TABLE [Resguardo].[tblCatPropiedadesArticulos] CHECK CONSTRAINT [Fk_ResguardoTblCatPropiedadesArticulos_ResguardoTblCatTiposPropiedades_IDTipoPropiedad]
GO
