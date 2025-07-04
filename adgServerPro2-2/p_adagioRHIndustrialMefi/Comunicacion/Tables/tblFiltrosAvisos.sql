USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Comunicacion].[tblFiltrosAvisos](
	[IDFiltroAviso] [int] IDENTITY(1,1) NOT NULL,
	[IDAviso] [int] NULL,
	[TipoFiltro] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Values] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
 CONSTRAINT [Pk_ComunicaciontblFiltrosAvisos_IDEstatus] PRIMARY KEY CLUSTERED 
(
	[IDFiltroAviso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Comunicacion].[tblFiltrosAvisos]  WITH CHECK ADD  CONSTRAINT [FK_ComunicaciontblFiltrosAvisos_ComunicaciontblAvisos_IDAviso] FOREIGN KEY([IDAviso])
REFERENCES [Comunicacion].[tblAvisos] ([IDAviso])
GO
ALTER TABLE [Comunicacion].[tblFiltrosAvisos] CHECK CONSTRAINT [FK_ComunicaciontblFiltrosAvisos_ComunicaciontblAvisos_IDAviso]
GO
