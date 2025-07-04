USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblDenuncias](
	[IDDenuncia] [int] IDENTITY(1,1) NOT NULL,
	[IDTipoDenuncia] [int] NOT NULL,
	[EsAnonima] [bit] NOT NULL,
	[IDEmpleadoDenunciante] [int] NULL,
	[IDTipoDenunciado] [int] NULL,
	[Denunciados] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescripcionHechos] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[DescripcionHechosHTML] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[FechaRegistro] [datetime] NULL,
	[FechaEvento] [datetime] NULL,
	[IDEstatusDenuncia] [int] NOT NULL,
	[Justificacion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuarioUpdate] [int] NULL,
	[FechaUpdate] [datetime] NULL,
	[IDCliente] [int] NULL,
 CONSTRAINT [Pk_Norma35tblDenuncias_IDDenuncia] PRIMARY KEY CLUSTERED 
(
	[IDDenuncia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblDenuncias]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblDenuncias_Norma35TblCatEstatusDenuncia_IDEstatusDenuncia] FOREIGN KEY([IDEstatusDenuncia])
REFERENCES [Norma35].[tblCatEstatusDenuncia] ([IDEstatusDenuncia])
GO
ALTER TABLE [Norma35].[tblDenuncias] CHECK CONSTRAINT [FK_Norma35TblDenuncias_Norma35TblCatEstatusDenuncia_IDEstatusDenuncia]
GO
ALTER TABLE [Norma35].[tblDenuncias]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblDenuncias_Norma35TblCatTiposDenunciadoa_IDTipoDenunciado] FOREIGN KEY([IDTipoDenunciado])
REFERENCES [Norma35].[tblCatTiposDenunciado] ([IDTipoDenunciado])
GO
ALTER TABLE [Norma35].[tblDenuncias] CHECK CONSTRAINT [FK_Norma35TblDenuncias_Norma35TblCatTiposDenunciadoa_IDTipoDenunciado]
GO
ALTER TABLE [Norma35].[tblDenuncias]  WITH CHECK ADD  CONSTRAINT [FK_Norma35TblDenuncias_Norma35TblCatTiposDenuncias_IDTipoDenuncia] FOREIGN KEY([IDTipoDenuncia])
REFERENCES [Norma35].[tblCatTiposDenuncias] ([IDTipoDenuncia])
GO
ALTER TABLE [Norma35].[tblDenuncias] CHECK CONSTRAINT [FK_Norma35TblDenuncias_Norma35TblCatTiposDenuncias_IDTipoDenuncia]
GO
