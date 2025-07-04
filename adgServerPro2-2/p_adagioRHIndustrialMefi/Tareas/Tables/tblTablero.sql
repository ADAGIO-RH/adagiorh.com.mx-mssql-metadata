USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Tareas].[tblTablero](
	[IDTablero] [int] IDENTITY(1,1) NOT NULL,
	[Titulo] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[Descripcion] [varchar](max) COLLATE SQL_Latin1_General_CP1_CI_AI NULL,
	[IDUsuarioCreacion] [int] NULL,
	[FechaRegistro] [datetime] NULL,
	[IDStyleBackground] [int] NULL,
 CONSTRAINT [Pk_TareasTblTablero_IDTablero] PRIMARY KEY CLUSTERED 
(
	[IDTablero] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Tareas].[tblTablero] ADD  DEFAULT (getdate()) FOR [FechaRegistro]
GO
ALTER TABLE [Tareas].[tblTablero]  WITH CHECK ADD  CONSTRAINT [FK_TareasTblTablero_TblCatStylesBackground_IDStyleBackground] FOREIGN KEY([IDStyleBackground])
REFERENCES [Tareas].[tblCatStylesBackground] ([IDStyleBackground])
GO
ALTER TABLE [Tareas].[tblTablero] CHECK CONSTRAINT [FK_TareasTblTablero_TblCatStylesBackground_IDStyleBackground]
GO
