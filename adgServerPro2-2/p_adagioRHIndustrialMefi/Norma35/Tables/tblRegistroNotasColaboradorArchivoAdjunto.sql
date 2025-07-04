USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Norma35].[tblRegistroNotasColaboradorArchivoAdjunto](
	[IDRegistroNotasColaboradorArchivoAdjunto] [int] IDENTITY(1,1) NOT NULL,
	[IDRegistroNotasColaborador] [int] NULL,
	[Name] [varchar](50) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[ContentType] [nvarchar](200) COLLATE SQL_Latin1_General_CP1_CI_AI NOT NULL,
	[Data] [varbinary](max) NOT NULL,
	[Notas] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuario] [int] NULL,
 CONSTRAINT [Pk_tblRegistroNotasColaboradorArchivoAdjunto_IDRegistroNotasColaboradorArchivoAdjunto] PRIMARY KEY CLUSTERED 
(
	[IDRegistroNotasColaboradorArchivoAdjunto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Norma35].[tblRegistroNotasColaboradorArchivoAdjunto]  WITH CHECK ADD  CONSTRAINT [FK_Norma35tblRegistroNotasColaboradorArchivoAdjunto_Norma35tblRegistroNotasColaborador_IDRegistroNotasColaborador] FOREIGN KEY([IDRegistroNotasColaborador])
REFERENCES [Norma35].[tblRegistroNotasColaborador] ([IDRegistroNotasColaborador])
GO
ALTER TABLE [Norma35].[tblRegistroNotasColaboradorArchivoAdjunto] CHECK CONSTRAINT [FK_Norma35tblRegistroNotasColaboradorArchivoAdjunto_Norma35tblRegistroNotasColaborador_IDRegistroNotasColaborador]
GO
