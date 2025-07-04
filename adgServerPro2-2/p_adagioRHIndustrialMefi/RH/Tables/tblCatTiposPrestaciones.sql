USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblCatTiposPrestaciones](
	[IDTipoPrestacion] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ConfianzaSindical] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Sindical] [bit] NULL,
	[PorcentajeFondoAhorro] [decimal](10, 3) NULL,
	[IDsConceptosFondoAhorro] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ToparFondoAhorro] [bit] NULL,
	[_Descripcion] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Traduccion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [PK_RHTblCatTiposPrestaciones_IDTipoPrestacion] PRIMARY KEY CLUSTERED 
(
	[IDTipoPrestacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [U_RHTblCatTiposPrestaciones_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblCatTiposPrestaciones] ADD  CONSTRAINT [D_RHTblCatTiposPrestaciones_Sindical]  DEFAULT ((0)) FOR [Sindical]
GO
ALTER TABLE [RH].[tblCatTiposPrestaciones] ADD  CONSTRAINT [D_RHTblCatTiposPrestaciones_ToparFondoAhorro]  DEFAULT ((1)) FOR [ToparFondoAhorro]
GO
ALTER TABLE [RH].[tblCatTiposPrestaciones]  WITH CHECK ADD  CONSTRAINT [Chk_RHtblCatTiposPrestaciones_Traduccion] CHECK  ((isjson([Traduccion])>(0)))
GO
ALTER TABLE [RH].[tblCatTiposPrestaciones] CHECK CONSTRAINT [Chk_RHtblCatTiposPrestaciones_Traduccion]
GO
