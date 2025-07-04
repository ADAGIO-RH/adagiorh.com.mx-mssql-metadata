USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RH].[tblRequisitosPuestos](
	[IDRequisitoPuesto] [int] IDENTITY(1,1) NOT NULL,
	[IDPuesto] [int] NOT NULL,
	[IDTipoCaracteristica] [int] NOT NULL,
	[Requisito] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Activo] [bit] NOT NULL,
	[TipoValor] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[ValorEsperado] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Data] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_RHTblRequisitosPuestos_IDRequisitoPuesto] PRIMARY KEY CLUSTERED 
(
	[IDRequisitoPuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [RH].[tblRequisitosPuestos] ADD  CONSTRAINT [D_RHTblRequisitosPuestos_Activo]  DEFAULT ((1)) FOR [Activo]
GO
ALTER TABLE [RH].[tblRequisitosPuestos]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblRequisitosPuestos_RHTblCatPuestos_IDPuesto] FOREIGN KEY([IDPuesto])
REFERENCES [RH].[tblCatPuestos] ([IDPuesto])
GO
ALTER TABLE [RH].[tblRequisitosPuestos] CHECK CONSTRAINT [Fk_RHTblRequisitosPuestos_RHTblCatPuestos_IDPuesto]
GO
ALTER TABLE [RH].[tblRequisitosPuestos]  WITH CHECK ADD  CONSTRAINT [Fk_RHTblRequisitosPuestos_RHTblCatTiposCaracteristicas_IDTipoCaracteristica] FOREIGN KEY([IDTipoCaracteristica])
REFERENCES [RH].[tblCatTiposCaracteristicas] ([IDTipoCaracteristica])
GO
ALTER TABLE [RH].[tblRequisitosPuestos] CHECK CONSTRAINT [Fk_RHTblRequisitosPuestos_RHTblCatTiposCaracteristicas_IDTipoCaracteristica]
GO
